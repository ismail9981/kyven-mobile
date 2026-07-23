import 'dart:async';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../domain/entities/personal_goal.dart';
import '../../domain/repositories/goals_repository.dart';
import 'goals_failure.dart';
import 'goals_schema.dart';

class HiveGoalsRepository implements GoalsRepository {
  HiveGoalsRepository({
    this.storageDirectory,
    this.boxName = GoalsSchema.boxName,
  });

  static bool _initialized = false;

  final String boxName;
  final String? storageDirectory;

  @override
  Stream<List<PersonalGoal>> watchGoals() async* {
    final box = await _box();
    yield _loadFromBox(box);
    yield* box.watch().map((_) => _loadFromBox(box));
  }

  @override
  Future<List<PersonalGoal>> loadGoals() async {
    final box = await _box();
    return _loadFromBox(box);
  }

  @override
  Future<void> createGoal(PersonalGoal goal) async {
    final box = await _box();
    if (box.containsKey(goal.id)) {
      return;
    }
    await _put(box, goal);
  }

  @override
  Future<void> updateGoal(PersonalGoal goal) async {
    final box = await _box();
    await _put(box, goal);
  }

  @override
  Future<void> archiveGoal(String id, DateTime archivedAt) async {
    final box = await _box();
    final goal = _GoalMapper.fromRecord(box.get(id));
    if (goal == null) {
      return;
    }
    await _put(
      box,
      goal.copyWith(
        status: GoalStatus.archived,
        archivedAt: archivedAt,
        updatedAt: archivedAt,
      ),
    );
  }

  Future<void> dispose() async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).close();
    }
  }

  Future<void> _put(Box<dynamic> box, PersonalGoal goal) async {
    try {
      await box.put(goal.id, _GoalMapper.toMap(goal));
    } catch (_) {
      throw const GoalsFailure('Personal goal could not be saved.');
    }
  }

  List<PersonalGoal> _loadFromBox(Box<dynamic> box) {
    final goals = <PersonalGoal>[];
    for (final key in box.keys) {
      if (key == GoalsSchema.versionKey) {
        continue;
      }
      final goal = _GoalMapper.fromRecord(box.get(key));
      if (goal != null) {
        goals.add(goal);
      }
    }
    goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return goals;
  }

  Future<Box<dynamic>> _box() async {
    await _ensureInitialized();
    try {
      final box = Hive.isBoxOpen(boxName)
          ? Hive.box<dynamic>(boxName)
          : await Hive.openBox<dynamic>(boxName, path: storageDirectory);
      final version = box.get(GoalsSchema.versionKey);
      if (version == null) {
        await box.put(GoalsSchema.versionKey, GoalsSchema.version);
      } else if (version != GoalsSchema.version) {
        throw const GoalsFailure('Goals storage needs a migration.');
      }
      return box;
    } on GoalsFailure {
      rethrow;
    } catch (_) {
      throw const GoalsFailure('Goals storage is unavailable.');
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      if (storageDirectory == null) {
        await Hive.initFlutter('kyven');
      } else {
        Hive.init(storageDirectory);
      }
      _initialized = true;
    } catch (_) {
      throw const GoalsFailure('Goals storage is unavailable.');
    }
  }
}

abstract final class _GoalMapper {
  static Map<String, Object?> toMap(PersonalGoal goal) {
    return {
      'id': goal.id,
      'title': goal.title,
      'type': goal.type.name,
      'targetValue': goal.targetValue,
      'periodType': goal.periodType.name,
      'startAt': goal.startAt.toIso8601String(),
      'endAt': goal.endAt.toIso8601String(),
      'createdAt': goal.createdAt.toIso8601String(),
      'updatedAt': goal.updatedAt.toIso8601String(),
      'status': goal.status.name,
      'unit': goal.unit.name,
      'completedAt': goal.completedAt?.toIso8601String(),
      'archivedAt': goal.archivedAt?.toIso8601String(),
    };
  }

  static PersonalGoal? fromRecord(Object? record) {
    if (record is! Map) {
      return null;
    }

    final id = _string(record['id']);
    final title = _string(record['title']);
    final type = _enumValue(GoalType.values, record['type']);
    final target = _doubleValue(record['targetValue']);
    final periodType = _enumValue(GoalPeriodType.values, record['periodType']);
    final startAt = _date(record['startAt']);
    final endAt = _date(record['endAt']);
    final createdAt = _date(record['createdAt']);
    final updatedAt = _date(record['updatedAt']) ?? createdAt;
    final status =
        _enumValue(GoalStatus.values, record['status']) ?? GoalStatus.active;
    final unit = _enumValue(GoalUnit.values, record['unit']) ?? _unitFor(type);

    if (id == null ||
        title == null ||
        type == null ||
        target == null ||
        target <= 0 ||
        periodType == null ||
        startAt == null ||
        endAt == null ||
        createdAt == null ||
        updatedAt == null ||
        unit == null ||
        !endAt.isAfter(startAt)) {
      return null;
    }

    return PersonalGoal(
      id: id,
      title: title,
      type: type,
      targetValue: target,
      periodType: periodType,
      startAt: startAt,
      endAt: endAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      unit: unit,
      completedAt: _date(record['completedAt']),
      archivedAt: _date(record['archivedAt']),
    );
  }

  static String? _string(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double? _doubleValue(Object? value) {
    if (value is double) return value.isFinite ? value : null;
    if (value is num) {
      final parsed = value.toDouble();
      return parsed.isFinite ? parsed : null;
    }
    return null;
  }

  static DateTime? _date(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static T? _enumValue<T extends Enum>(List<T> values, Object? value) {
    if (value is! String) return null;
    for (final item in values) {
      if (item.name == value) return item;
    }
    return null;
  }

  static GoalUnit? _unitFor(GoalType? type) {
    return switch (type) {
      GoalType.distance => GoalUnit.kilometers,
      GoalType.runCount => GoalUnit.runs,
      GoalType.duration => GoalUnit.minutes,
      GoalType.calories => GoalUnit.calories,
      null => null,
    };
  }
}
