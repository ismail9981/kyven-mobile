import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_route.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_route_point.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_statistics.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/saved_run.dart';
import 'package:kyven_mobile/features/run_tracking/infrastructure/repositories/hive_run_history_repository.dart';
import 'package:kyven_mobile/features/run_tracking/infrastructure/repositories/run_history_schema.dart';

void main() {
  late Directory directory;
  late String boxName;
  late HiveRunHistoryRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('kyven-run-history-');
    boxName = 'run_history_${DateTime.now().microsecondsSinceEpoch}';
    repository = HiveRunHistoryRepository(
      storageDirectory: directory.path,
      boxName: boxName,
    );
  });

  tearDown(() async {
    await repository.dispose();
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).close();
    }
    await Hive.deleteBoxFromDisk(boxName, path: directory.path);
    await directory.delete(recursive: true);
  });

  test('saves a completed run', () async {
    final run = _run(id: 'run-1');

    await repository.saveRun(run);

    expect(await repository.getRunById('run-1'), run);
  });

  test('serializes and deserializes saved route segments', () async {
    final run = _run(id: 'routed', route: _route());

    await repository.saveRun(run);

    final restored = await repository.getRunById('routed');
    expect(restored?.route, run.route);
    expect(restored?.route.segments, hasLength(2));
    expect(restored?.route.segments.first.points, hasLength(2));
    expect(restored?.route.segments.last.points, hasLength(2));
  });

  test('route data survives repository reinitialization', () async {
    await repository.saveRun(_run(id: 'persisted-route', route: _route()));
    await repository.dispose();

    final restored = HiveRunHistoryRepository(
      storageDirectory: directory.path,
      boxName: boxName,
    );
    addTearDown(restored.dispose);

    final run = await restored.getRunById('persisted-route');
    expect(run?.route.segments, hasLength(2));
    expect(run?.route.segments.first.points.first.latitude, 25.2048);
  });

  test('save occurs only once for duplicate run IDs', () async {
    final run = _run(id: 'run-1');

    await repository.saveRun(run);
    await repository.saveRun(run);

    expect(await repository.getAllRuns(), hasLength(1));
  });

  test('reads persisted history newest first', () async {
    final older = _run(id: 'older', completedAt: DateTime(2026, 7, 18, 7));
    final newer = _run(id: 'newer', completedAt: DateTime(2026, 7, 19, 7));

    await repository.saveRun(older);
    await repository.saveRun(newer);

    final runs = await repository.getAllRuns();

    expect(runs.map((run) => run.id), ['newer', 'older']);
  });

  test('latest run returns newest completed run', () async {
    await repository.saveRun(
      _run(id: 'older', completedAt: DateTime(2026, 7, 17, 7)),
    );
    await repository.saveRun(
      _run(id: 'latest', completedAt: DateTime(2026, 7, 19, 7)),
    );

    expect((await repository.getLatestRun())?.id, 'latest');
  });

  test('statistics from empty history are neutral', () async {
    expect(await repository.getStatistics(), RunStatistics.empty());
  });

  test('statistics from one run are deterministic', () async {
    await repository.saveRun(_run(distanceKm: 5, duration: _minutes(25)));

    final stats = await repository.getStatistics();

    expect(stats.totalRuns, 1);
    expect(stats.totalDistanceKm, 5);
    expect(stats.totalDuration, _minutes(25));
    expect(stats.averageDistanceKm, 5);
    expect(stats.longestRunKm, 5);
    expect(stats.fastestFiveKilometerPace, _minutes(5));
  });

  test('statistics from multiple runs aggregate values', () async {
    await repository.saveRun(
      _run(
        id: 'run-1',
        distanceKm: 4,
        duration: _minutes(24),
        averagePace: _minutes(6),
      ),
    );
    await repository.saveRun(
      _run(
        id: 'run-2',
        distanceKm: 6,
        duration: _minutes(30),
        averagePace: _minutes(5),
      ),
    );

    final stats = await repository.getStatistics();

    expect(stats.totalRuns, 2);
    expect(stats.totalDistanceKm, 10);
    expect(stats.totalDuration, _minutes(54));
    expect(stats.averageDistanceKm, 5);
    expect(stats.averagePace, const Duration(minutes: 5, seconds: 30));
    expect(stats.longestRunKm, 6);
  });

  test('delete run updates statistics', () async {
    await repository.saveRun(_run(id: 'run-1', distanceKm: 4));
    await repository.saveRun(_run(id: 'run-2', distanceKm: 6));

    await repository.deleteRun('run-2');

    final stats = await repository.getStatistics();

    expect(stats.totalRuns, 1);
    expect(stats.totalDistanceKm, 4);
  });

  test('clear history removes runs', () async {
    await repository.saveRun(_run());

    await repository.clearHistory();

    expect(await repository.getAllRuns(), isEmpty);
  });

  test('invalid records are ignored', () async {
    await repository.saveRun(_run(id: 'valid'));
    final box = Hive.box<dynamic>(boxName);
    await box.put('invalid', {
      'id': '',
      'startedAt': 'not-a-date',
      'distanceKm': -10,
    });

    final runs = await repository.getAllRuns();
    final stats = await repository.getStatistics();

    expect(runs.map((run) => run.id), ['valid']);
    expect(stats.totalRuns, 1);
  });

  test('data survives repository reinitialization', () async {
    await repository.saveRun(_run(id: 'persisted'));
    await repository.dispose();

    final restored = HiveRunHistoryRepository(
      storageDirectory: directory.path,
      boxName: boxName,
    );
    addTearDown(restored.dispose);

    expect((await restored.getRunById('persisted'))?.id, 'persisted');
  });

  test('version one records migrate safely with empty route', () async {
    final box = await Hive.openBox<dynamic>(boxName, path: directory.path);
    await box.put(RunHistorySchema.versionKey, 1);
    await box.put('legacy-run', {
      'id': 'legacy-run',
      'startedAt': DateTime(2026, 7, 19, 7).toIso8601String(),
      'completedAt': DateTime(2026, 7, 19, 7, 30).toIso8601String(),
      'durationMs': const Duration(minutes: 30).inMilliseconds,
      'distanceKm': 5.0,
      'averagePaceMs': const Duration(minutes: 6).inMilliseconds,
      'calories': 340,
      'cadence': 170,
      'averageHeartRate': 142,
      'routePreview': '',
      'achievement': 'Legacy run',
    });

    final migrated = await repository.getRunById('legacy-run');
    expect(migrated?.route.segments, isEmpty);
    expect(box.get(RunHistorySchema.versionKey), RunHistorySchema.version);
  });
}

SavedRun _run({
  String id = 'run-1',
  DateTime? completedAt,
  double distanceKm = 5.2,
  Duration duration = const Duration(minutes: 28, seconds: 40),
  Duration? averagePace,
  RunRoute? route,
}) {
  final completed = completedAt ?? DateTime(2026, 7, 19, 7, 30);
  return SavedRun(
    id: id,
    startedAt: completed.subtract(duration),
    completedAt: completed,
    duration: duration,
    distanceKm: distanceKm,
    averagePace:
        averagePace ??
        Duration(
          seconds: distanceKm == 0
              ? 0
              : (duration.inSeconds / distanceKm).round(),
        ),
    calories: (distanceKm * 68).round(),
    cadence: 170,
    averageHeartRate: 142,
    routePreview: '',
    achievement: 'First movement logged',
    route: route,
  );
}

Duration _minutes(int value) => Duration(minutes: value);

RunRoute _route() {
  return RunRoute.empty()
      .appendPoint(_routePoint(25.2048, 55.2708, 0))
      .appendPoint(_routePoint(25.205, 55.271, 60))
      .closeActiveSegment()
      .appendPoint(_routePoint(25.206, 55.272, 120))
      .appendPoint(_routePoint(25.207, 55.273, 180))
      .closeActiveSegment();
}

RunRoutePoint _routePoint(double latitude, double longitude, int seconds) {
  return RunRoutePoint(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime(2026, 7, 19, 7).add(Duration(seconds: seconds)),
  );
}
