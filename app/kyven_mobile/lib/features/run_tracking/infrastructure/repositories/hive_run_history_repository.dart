import 'dart:async';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../domain/entities/run_route.dart';
import '../../domain/entities/run_route_point.dart';
import '../../domain/entities/run_route_segment.dart';
import '../../domain/entities/run_statistics.dart';
import '../../domain/entities/saved_run.dart';
import '../../domain/repositories/run_history_repository.dart';
import 'run_history_failure.dart';
import 'run_history_schema.dart';

class HiveRunHistoryRepository implements RunHistoryRepository {
  HiveRunHistoryRepository({
    this.storageDirectory,
    this.boxName = RunHistorySchema.boxName,
  });

  final String boxName;
  final String? storageDirectory;

  static bool _initialized = false;

  final _changes = StreamController<List<SavedRun>>.broadcast();

  @override
  Future<void> saveRun(SavedRun run) async {
    if (!run.isValid) {
      throw const RunHistoryFailure('This run cannot be saved.');
    }

    final box = await _box();
    try {
      if (box.containsKey(run.id)) {
        return;
      }
      await box.put(run.id, _RunHistoryMapper.toMap(run));
      await _emitChanges();
    } on RunHistoryFailure {
      rethrow;
    } catch (_) {
      throw const RunHistoryFailure('We could not save this run.');
    }
  }

  @override
  Future<List<SavedRun>> getAllRuns() async {
    final box = await _box();
    try {
      final runs = <SavedRun>[];
      for (final key in box.keys) {
        if (key == RunHistorySchema.versionKey) {
          continue;
        }
        final value = box.get(key);
        final run = _RunHistoryMapper.fromRecord(value);
        if (run != null && run.isValid) {
          runs.add(run);
        }
      }
      runs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return runs;
    } catch (_) {
      throw const RunHistoryFailure('We could not load run history.');
    }
  }

  @override
  Future<SavedRun?> getLatestRun() async {
    final runs = await getAllRuns();
    return runs.isEmpty ? null : runs.first;
  }

  @override
  Future<SavedRun?> getRunById(String id) async {
    if (id.trim().isEmpty) {
      throw const RunHistoryFailure('Run details are unavailable.');
    }

    final box = await _box();
    try {
      final run = _RunHistoryMapper.fromRecord(box.get(id));
      return run != null && run.isValid ? run : null;
    } catch (_) {
      throw const RunHistoryFailure('Run details are unavailable.');
    }
  }

  @override
  Future<void> deleteRun(String id) async {
    if (id.trim().isEmpty) {
      throw const RunHistoryFailure('Run details are unavailable.');
    }

    final box = await _box();
    try {
      await box.delete(id);
      await _emitChanges();
    } catch (_) {
      throw const RunHistoryFailure('We could not delete this run.');
    }
  }

  @override
  Future<void> clearHistory() async {
    final box = await _box();
    try {
      final version = box.get(RunHistorySchema.versionKey);
      await box.clear();
      await box.put(RunHistorySchema.versionKey, version);
      await _emitChanges();
    } catch (_) {
      throw const RunHistoryFailure('We could not clear run history.');
    }
  }

  @override
  Stream<List<SavedRun>> watchRuns() async* {
    yield await getAllRuns();
    yield* _changes.stream;
  }

  @override
  Future<RunStatistics> getStatistics() async {
    return RunStatistics.fromRuns(await getAllRuns());
  }

  Future<void> dispose() async {
    await _changes.close();
  }

  Future<void> _emitChanges() async {
    if (!_changes.isClosed) {
      _changes.add(await getAllRuns());
    }
  }

  Future<Box<dynamic>> _box() async {
    await _ensureInitialized();
    try {
      final box = Hive.isBoxOpen(boxName)
          ? Hive.box<dynamic>(boxName)
          : await Hive.openBox<dynamic>(boxName, path: storageDirectory);

      final version = box.get(RunHistorySchema.versionKey);
      if (version == null) {
        await box.put(RunHistorySchema.versionKey, RunHistorySchema.version);
      } else if (version == 1) {
        await box.put(RunHistorySchema.versionKey, RunHistorySchema.version);
      } else if (version != RunHistorySchema.version) {
        throw const RunHistoryFailure('Run history needs a migration.');
      }
      return box;
    } on RunHistoryFailure {
      rethrow;
    } catch (_) {
      throw const RunHistoryFailure('Run history is unavailable.');
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
      throw const RunHistoryFailure('Run history is unavailable.');
    }
  }
}

abstract final class _RunHistoryMapper {
  static Map<String, Object?> toMap(SavedRun run) {
    return {
      'id': run.id,
      'startedAt': run.startedAt.toIso8601String(),
      'completedAt': run.completedAt.toIso8601String(),
      'durationMs': run.duration.inMilliseconds,
      'distanceKm': run.distanceKm,
      'averagePaceMs': run.averagePace.inMilliseconds,
      'calories': run.calories,
      'cadence': run.cadence,
      'averageHeartRate': run.averageHeartRate,
      'routePreview': run.routePreview,
      'achievement': run.achievement,
      'route': _RunRouteMapper.toMap(run.route),
    };
  }

  static SavedRun? fromRecord(Object? record) {
    if (record is! Map) {
      return null;
    }

    final map = Map<String, Object?>.from(record);
    final id = map['id'];
    final startedAt = DateTime.tryParse('${map['startedAt']}');
    final completedAt = DateTime.tryParse('${map['completedAt']}');
    final durationMs = _intValue(map['durationMs']);
    final distanceKm = _doubleValue(map['distanceKm']);
    final averagePaceMs = _intValue(map['averagePaceMs']);
    final calories = _intValue(map['calories']);
    final cadence = _intValue(map['cadence']);
    final averageHeartRate = _intValue(map['averageHeartRate']);

    if (id is! String ||
        startedAt == null ||
        completedAt == null ||
        durationMs == null ||
        distanceKm == null ||
        averagePaceMs == null ||
        calories == null ||
        cadence == null ||
        averageHeartRate == null) {
      return null;
    }

    return SavedRun(
      id: id,
      startedAt: startedAt,
      completedAt: completedAt,
      duration: Duration(milliseconds: durationMs),
      distanceKm: distanceKm,
      averagePace: Duration(milliseconds: averagePaceMs),
      calories: calories,
      cadence: cadence,
      averageHeartRate: averageHeartRate,
      routePreview: '${map['routePreview'] ?? ''}',
      achievement: '${map['achievement'] ?? ''}',
      route: _RunRouteMapper.fromRecord(map['route']),
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

abstract final class _RunRouteMapper {
  static Map<String, Object?> toMap(RunRoute route) {
    return {
      'segments': route.segments
          .map(
            (segment) => {
              'points': segment.points
                  .map(
                    (point) => {
                      'latitude': point.latitude,
                      'longitude': point.longitude,
                      'timestamp': point.timestamp.toIso8601String(),
                    },
                  )
                  .toList(growable: false),
            },
          )
          .toList(growable: false),
    };
  }

  static RunRoute fromRecord(Object? record) {
    if (record is! Map) {
      return RunRoute.empty();
    }

    final segmentsRecord = record['segments'];
    if (segmentsRecord is! Iterable) {
      return RunRoute.empty();
    }

    final segments = <RunRouteSegment>[];
    for (final segmentRecord in segmentsRecord) {
      final segment = _segmentFromRecord(segmentRecord);
      if (segment.points.isNotEmpty) {
        segments.add(segment);
      }
    }
    return RunRoute(segments: segments);
  }

  static RunRouteSegment _segmentFromRecord(Object? record) {
    if (record is! Map) {
      return RunRouteSegment(points: const [], isOpen: false);
    }

    final pointsRecord = record['points'];
    if (pointsRecord is! Iterable) {
      return RunRouteSegment(points: const [], isOpen: false);
    }

    final points = <RunRoutePoint>[];
    for (final pointRecord in pointsRecord) {
      final point = _pointFromRecord(pointRecord);
      if (point != null) {
        points.add(point);
      }
    }
    return RunRouteSegment(points: points, isOpen: false);
  }

  static RunRoutePoint? _pointFromRecord(Object? record) {
    if (record is! Map) {
      return null;
    }

    final latitude = _RunHistoryMapper._doubleValue(record['latitude']);
    final longitude = _RunHistoryMapper._doubleValue(record['longitude']);
    final timestamp = DateTime.tryParse('${record['timestamp']}');
    if (latitude == null || longitude == null || timestamp == null) {
      return null;
    }

    return RunRoutePoint(
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
    );
  }
}
