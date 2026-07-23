import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyven_mobile/app/app.dart';
import 'package:kyven_mobile/features/analytics/application/analytics_providers.dart';
import 'package:kyven_mobile/features/gamification/application/gamification_providers.dart';
import 'package:kyven_mobile/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:kyven_mobile/features/goals/application/goals_providers.dart';
import 'package:kyven_mobile/features/goals/domain/entities/personal_goal.dart';
import 'package:kyven_mobile/features/goals/domain/repositories/goals_repository.dart';
import 'package:kyven_mobile/features/run_tracking/application/location_repository_provider.dart';
import 'package:kyven_mobile/features/run_tracking/application/run_history_providers.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_route.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/saved_run.dart';
import 'package:kyven_mobile/features/training/application/training_providers.dart';
import 'package:kyven_mobile/features/training/domain/repositories/training_repository.dart';

import '../fakes/fake_gamification_repository.dart';
import '../fakes/fake_goals_repository.dart';
import '../fakes/fake_location_tracking_repository.dart';
import '../fakes/fake_run_history_repository.dart';
import '../fakes/fake_training_repository.dart';

Widget testApp({
  List<SavedRun> runs = const [],
  FakeLocationTrackingRepository? locationRepository,
  FakeRunHistoryRepository? repository,
  TrainingRepository? trainingRepository,
  GamificationRepository? gamificationRepository,
  GoalsRepository? goalsRepository,
  DateTime? analyticsNow,
  DateTime? goalsNow,
}) {
  return ProviderScope(
    overrides: [
      if (analyticsNow != null)
        analyticsNowProvider.overrideWithValue(analyticsNow),
      if (goalsNow != null) goalsNowProvider.overrideWithValue(goalsNow),
      runHistoryRepositoryProvider.overrideWithValue(
        repository ?? FakeRunHistoryRepository(runs),
      ),
      locationTrackingRepositoryProvider.overrideWithValue(
        locationRepository ?? FakeLocationTrackingRepository(),
      ),
      trainingRepositoryProvider.overrideWithValue(
        trainingRepository ?? FakeTrainingRepository(),
      ),
      gamificationRepositoryProvider.overrideWithValue(
        gamificationRepository ?? FakeGamificationRepository(),
      ),
      goalsRepositoryProvider.overrideWithValue(
        goalsRepository ?? FakeGoalsRepository(),
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
  RunRoute? route,
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
    route: route,
  );
}

PersonalGoal personalGoalFixture({
  String id = 'goal-1',
  String title = 'Weekly 10K',
  GoalType type = GoalType.distance,
  double targetValue = 10,
  GoalPeriodType periodType = GoalPeriodType.weekly,
  DateTime? startAt,
  DateTime? endAt,
  DateTime? createdAt,
  DateTime? updatedAt,
  GoalStatus status = GoalStatus.active,
  GoalUnit unit = GoalUnit.kilometers,
  DateTime? completedAt,
  DateTime? archivedAt,
}) {
  final start = startAt ?? DateTime(2026, 7, 20);
  return PersonalGoal(
    id: id,
    title: title,
    type: type,
    targetValue: targetValue,
    periodType: periodType,
    startAt: start,
    endAt: endAt ?? start.add(const Duration(days: 7)),
    createdAt: createdAt ?? start,
    updatedAt: updatedAt ?? start,
    status: status,
    unit: unit,
    completedAt: completedAt,
    archivedAt: archivedAt,
  );
}
