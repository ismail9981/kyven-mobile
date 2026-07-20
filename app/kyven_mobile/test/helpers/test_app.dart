import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyven_mobile/app/app.dart';
import 'package:kyven_mobile/features/run_tracking/application/run_history_providers.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/saved_run.dart';

import '../fakes/fake_run_history_repository.dart';

Widget testApp({
  List<SavedRun> runs = const [],
  FakeRunHistoryRepository? repository,
}) {
  return ProviderScope(
    overrides: [
      runHistoryRepositoryProvider.overrideWithValue(
        repository ?? FakeRunHistoryRepository(runs),
      ),
    ],
    child: const KyvenApp(),
  );
}

SavedRun savedRunFixture({
  String id = 'run-1',
  DateTime? startedAt,
  DateTime? completedAt,
  Duration duration = const Duration(minutes: 28, seconds: 40),
  double distanceKm = 5.2,
  Duration averagePace = const Duration(minutes: 5, seconds: 31),
  int calories = 354,
  int cadence = 170,
  int averageHeartRate = 142,
  String achievement = 'First movement logged',
}) {
  final completed = completedAt ?? DateTime(2026, 7, 19, 7, 30);
  return SavedRun(
    id: id,
    startedAt: startedAt ?? completed.subtract(duration),
    completedAt: completed,
    duration: duration,
    distanceKm: distanceKm,
    averagePace: averagePace,
    calories: calories,
    cadence: cadence,
    averageHeartRate: averageHeartRate,
    routePreview: '',
    achievement: achievement,
  );
}
