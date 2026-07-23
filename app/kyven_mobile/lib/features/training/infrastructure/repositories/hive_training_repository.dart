import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../domain/entities/training_plan.dart';
import '../../domain/entities/training_progress.dart';
import '../../domain/repositories/training_repository.dart';
import '../../domain/services/built_in_training_plans.dart';
import 'training_failure.dart';
import 'training_schema.dart';

class HiveTrainingRepository implements TrainingRepository {
  HiveTrainingRepository({
    this.storageDirectory,
    this.boxName = TrainingSchema.boxName,
  });

  static bool _initialized = false;

  final String boxName;
  final String? storageDirectory;

  @override
  Future<List<TrainingPlan>> getPlans() async {
    return BuiltInTrainingPlans.all;
  }

  @override
  Future<TrainingPlan?> getPlan(String id) async {
    if (id.trim().isEmpty) {
      return null;
    }
    return BuiltInTrainingPlans.byId(id);
  }

  @override
  Future<TrainingProgress> loadProgress(String planId) async {
    final box = await _box();
    try {
      final progress = _TrainingProgressMapper.fromRecord(
        planId: planId,
        record: box.get(planId),
      );
      return progress ?? TrainingProgress.empty(planId);
    } catch (_) {
      throw const TrainingFailure('Training progress is unavailable.');
    }
  }

  @override
  Future<void> saveProgress(TrainingProgress progress) async {
    final box = await _box();
    try {
      await box.put(progress.planId, _TrainingProgressMapper.toMap(progress));
    } catch (_) {
      throw const TrainingFailure('Training progress could not be saved.');
    }
  }

  Future<Box<dynamic>> _box() async {
    await _ensureInitialized();
    try {
      final box = Hive.isBoxOpen(boxName)
          ? Hive.box<dynamic>(boxName)
          : await Hive.openBox<dynamic>(boxName, path: storageDirectory);
      final version = box.get(TrainingSchema.versionKey);
      if (version == null) {
        await box.put(TrainingSchema.versionKey, TrainingSchema.version);
      } else if (version != TrainingSchema.version) {
        throw const TrainingFailure('Training storage needs a migration.');
      }
      return box;
    } on TrainingFailure {
      rethrow;
    } catch (_) {
      throw const TrainingFailure('Training storage is unavailable.');
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    try {
      if (storageDirectory == null) {
        await Hive.initFlutter('kyven');
      } else {
        Hive.init(storageDirectory);
      }
      _initialized = true;
    } catch (_) {
      throw const TrainingFailure('Training storage is unavailable.');
    }
  }
}

abstract final class _TrainingProgressMapper {
  static Map<String, Object?> toMap(TrainingProgress progress) {
    return {
      'planId': progress.planId,
      'completedSessions': progress.completedSessions.toList(growable: false),
      'currentWeek': progress.currentWeek,
      'currentDay': progress.currentDay,
      'completionPercentage': progress.completionPercentage,
    };
  }

  static TrainingProgress? fromRecord({
    required String planId,
    required Object? record,
  }) {
    if (record is! Map) {
      return null;
    }

    final completedRecord = record['completedSessions'];
    final currentWeek = _intValue(record['currentWeek']);
    final currentDay = _intValue(record['currentDay']);
    final completionPercentage = _doubleValue(record['completionPercentage']);

    if (completedRecord is! Iterable ||
        currentWeek == null ||
        currentDay == null ||
        completionPercentage == null) {
      return null;
    }

    return TrainingProgress(
      planId: '${record['planId'] ?? planId}',
      completedSessions: completedRecord
          .map((value) => '$value')
          .where((value) => value.trim().isNotEmpty)
          .toSet(),
      currentWeek: currentWeek,
      currentDay: currentDay,
      completionPercentage: completionPercentage.clamp(0, 1),
    );
  }

  static int? _intValue(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  static double? _doubleValue(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }
}
