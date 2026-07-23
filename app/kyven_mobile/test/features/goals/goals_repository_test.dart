import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kyven_mobile/features/goals/domain/entities/personal_goal.dart';
import 'package:kyven_mobile/features/goals/infrastructure/repositories/goals_schema.dart';
import 'package:kyven_mobile/features/goals/infrastructure/repositories/hive_goals_repository.dart';

import '../../helpers/test_app.dart';

void main() {
  group('HiveGoalsRepository', () {
    late Directory directory;
    late String boxName;
    late HiveGoalsRepository repository;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('kyven-goals-');
      boxName = 'goals_${DateTime.now().microsecondsSinceEpoch}';
      repository = HiveGoalsRepository(
        storageDirectory: directory.path,
        boxName: boxName,
      );
    });

    tearDown(() async {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<dynamic>(boxName).close();
      }
      await Hive.deleteBoxFromDisk(boxName, path: directory.path);
      await directory.delete(recursive: true);
    });

    test('empty box loads safely and writes version', () async {
      expect(await repository.loadGoals(), isEmpty);

      final box = Hive.box<dynamic>(boxName);
      expect(box.get(GoalsSchema.versionKey), GoalsSchema.version);
    });

    test('create and restore goal with stable id and completedAt', () async {
      final completedAt = DateTime(2026, 7, 22);
      final goal = personalGoalFixture(
        completedAt: completedAt,
        status: GoalStatus.completed,
      );

      await repository.createGoal(goal);
      await Hive.box<dynamic>(boxName).close();

      final restoredRepository = HiveGoalsRepository(
        storageDirectory: directory.path,
        boxName: boxName,
      );
      final restored = await restoredRepository.loadGoals();

      expect(restored.single.id, goal.id);
      expect(restored.single.completedAt, completedAt);
      expect(restored.single.status, GoalStatus.completed);
    });

    test('update and archive goal', () async {
      final goal = personalGoalFixture();
      final archivedAt = DateTime(2026, 7, 23);

      await repository.createGoal(goal);
      await repository.updateGoal(goal.copyWith(title: 'Updated Goal'));
      await repository.archiveGoal(goal.id, archivedAt);

      final restored = await repository.loadGoals();
      expect(restored.single.title, 'Updated Goal');
      expect(restored.single.status, GoalStatus.archived);
      expect(restored.single.archivedAt, archivedAt);
    });

    test('multiple goals are restored newest first', () async {
      await repository.createGoal(
        personalGoalFixture(id: 'old', createdAt: DateTime(2026, 7, 1)),
      );
      await repository.createGoal(
        personalGoalFixture(id: 'new', createdAt: DateTime(2026, 7, 2)),
      );

      final restored = await repository.loadGoals();

      expect(restored.map((goal) => goal.id), ['new', 'old']);
    });

    test('missing and malformed optional fields recover safely', () async {
      final box = await Hive.openBox<dynamic>(boxName, path: directory.path);
      await box.put(GoalsSchema.versionKey, GoalsSchema.version);
      await box.put('legacy', {
        'id': 'legacy',
        'title': 'Legacy',
        'type': 'distance',
        'targetValue': 12,
        'periodType': 'weekly',
        'startAt': DateTime(2026, 7, 20).toIso8601String(),
        'endAt': DateTime(2026, 7, 27).toIso8601String(),
        'createdAt': DateTime(2026, 7, 20).toIso8601String(),
        'completedAt': 'not-a-date',
      });
      await box.put('bad', {'id': 'bad'});

      final restored = await repository.loadGoals();

      expect(restored, hasLength(1));
      expect(restored.single.id, 'legacy');
      expect(restored.single.completedAt, isNull);
      expect(restored.single.unit, GoalUnit.kilometers);
    });
  });
}
