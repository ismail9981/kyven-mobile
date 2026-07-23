import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kyven_mobile/features/training/domain/entities/training_progress.dart';
import 'package:kyven_mobile/features/training/domain/services/built_in_training_plans.dart';
import 'package:kyven_mobile/features/training/domain/services/training_progress_calculator.dart';
import 'package:kyven_mobile/features/training/infrastructure/repositories/hive_training_repository.dart';
import 'package:kyven_mobile/features/training/infrastructure/repositories/training_schema.dart';

void main() {
  group('BuiltInTrainingPlans', () {
    test('loads the required initial plans', () {
      final plans = BuiltInTrainingPlans.all;

      expect(plans.map((plan) => plan.title), [
        'Beginner 5K',
        'Improve Pace',
        '10K Preparation',
      ]);
      expect(plans.first.durationWeeks, 8);
      expect(plans[1].durationWeeks, 6);
      expect(plans[2].durationWeeks, 10);
      expect(plans.every((plan) => plan.days.isNotEmpty), isTrue);
    });
  });

  group('TrainingProgressCalculator', () {
    const calculator = TrainingProgressCalculator();

    test('calculates completion percentage', () {
      expect(
        calculator.completionPercentage(completedSessions: 2, totalSessions: 8),
        0.25,
      );
      expect(
        calculator.completionPercentage(completedSessions: 2, totalSessions: 0),
        0,
      );
    });

    test('completion updates progress to the next incomplete day', () {
      final plan = BuiltInTrainingPlans.byId('beginner-5k')!;
      final firstDay = plan.days.first;

      final progress = calculator.completeSession(
        plan: plan,
        progress: TrainingProgress.empty(plan.id),
        day: firstDay,
      );

      expect(progress.completedSessions, contains(firstDay.sessionKey));
      expect(progress.currentWeek, 1);
      expect(progress.currentDay, 2);
      expect(progress.completionPercentage, 1 / plan.sessionCount);
    });

    test('normalizes restored progress against the selected plan', () {
      final plan = BuiltInTrainingPlans.byId('beginner-5k')!;
      final progress = calculator.normalize(
        plan: plan,
        progress: TrainingProgress(
          planId: plan.id,
          completedSessions: {plan.days.first.sessionKey, 'legacy-session'},
          currentWeek: 99,
          currentDay: 99,
          completionPercentage: 1,
        ),
      );

      expect(progress.completedSessions, {plan.days.first.sessionKey});
      expect(progress.currentWeek, 1);
      expect(progress.currentDay, 2);
      expect(progress.completionPercentage, 1 / plan.sessionCount);
    });
  });

  group('HiveTrainingRepository', () {
    late Directory directory;
    late String boxName;
    late HiveTrainingRepository repository;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('kyven-training-');
      boxName = 'training_${DateTime.now().microsecondsSinceEpoch}';
      repository = HiveTrainingRepository(
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

    test('repository loads built-in plans', () async {
      final plans = await repository.getPlans();

      expect(plans, hasLength(3));
      expect((await repository.getPlan('beginner-5k'))?.title, 'Beginner 5K');
      expect(await repository.getPlan('missing'), isNull);
    });

    test('progress save and restore survives repository recreation', () async {
      final progress = TrainingProgress(
        planId: 'beginner-5k',
        completedSessions: const {'w1-d1', 'w1-d2'},
        currentWeek: 1,
        currentDay: 3,
        completionPercentage: 0.25,
      );

      await repository.saveProgress(progress);
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<dynamic>(boxName).close();
      }

      final restored = HiveTrainingRepository(
        storageDirectory: directory.path,
        boxName: boxName,
      );

      expect(await restored.loadProgress('beginner-5k'), progress);
    });

    test('empty progress restores neutral state', () async {
      final progress = await repository.loadProgress('improve-pace');

      expect(progress, TrainingProgress.empty('improve-pace'));
      final box = Hive.box<dynamic>(boxName);
      expect(box.get(TrainingSchema.versionKey), TrainingSchema.version);
    });
  });
}
