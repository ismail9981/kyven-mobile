import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/features/analytics/domain/entities/analytics_comparison.dart';
import 'package:kyven_mobile/features/analytics/domain/entities/personal_records.dart';
import 'package:kyven_mobile/features/analytics/domain/entities/training_load_snapshot.dart';
import 'package:kyven_mobile/features/analytics/domain/services/analytics_period_calculator.dart';
import 'package:kyven_mobile/features/analytics/domain/services/run_analytics_engine.dart';

import '../../helpers/test_app.dart';

void main() {
  const periods = AnalyticsPeriodCalculator();
  const engine = RunAnalyticsEngine();
  final now = DateTime(2026, 7, 22, 12);

  test('uses Monday based half-open calendar weeks', () {
    final week = periods.currentWeek(now);

    expect(week.start, DateTime(2026, 7, 20));
    expect(week.end, DateTime(2026, 7, 27));
    expect(week.contains(DateTime(2026, 7, 20)), isTrue);
    expect(week.contains(DateTime(2026, 7, 27)), isFalse);
  });

  test('summarizes current week with aggregate pace', () {
    final snapshot = engine.analyze(
      now: now,
      runs: [
        savedRunFixture(
          id: 'a',
          completedAt: DateTime(2026, 7, 20, 7),
          distanceKm: 5,
          duration: const Duration(minutes: 25),
        ),
        savedRunFixture(
          id: 'b',
          completedAt: DateTime(2026, 7, 22, 7),
          distanceKm: 10,
          duration: const Duration(minutes: 60),
          calories: 700,
        ),
        savedRunFixture(
          id: 'old',
          completedAt: DateTime(2026, 7, 12, 7),
          distanceKm: 3,
        ),
      ],
    );

    expect(snapshot.currentWeek.runCount, 2);
    expect(snapshot.currentWeek.totalDistanceKm, 15);
    expect(snapshot.currentWeek.totalCalories, 1054);
    expect(snapshot.currentWeek.averagePace, const Duration(seconds: 340));
    expect(snapshot.currentWeek.longestRunDistanceKm, 10);
  });

  test('compares week, month, and pace improvement safely', () {
    final snapshot = engine.analyze(
      now: now,
      runs: [
        savedRunFixture(
          id: 'current',
          completedAt: DateTime(2026, 7, 21),
          distanceKm: 10,
          duration: const Duration(minutes: 50),
        ),
        savedRunFixture(
          id: 'previous',
          completedAt: DateTime(2026, 7, 14),
          distanceKm: 5,
          duration: const Duration(minutes: 30),
        ),
        savedRunFixture(
          id: 'previous-month',
          completedAt: DateTime(2026, 6, 14),
          distanceKm: 2,
          duration: const Duration(minutes: 12),
        ),
      ],
    );

    expect(snapshot.weeklyComparison.distanceChangePercent, 100);
    expect(
      snapshot.weeklyComparison.paceImprovementPercent,
      closeTo(16.7, 0.1),
    );
    expect(snapshot.monthlyComparison.distanceChangePercent, closeTo(650, 0.1));
  });

  test('handles zero baselines without infinity', () {
    final snapshot = engine.analyze(
      now: now,
      runs: [
        savedRunFixture(completedAt: DateTime(2026, 7, 21), distanceKm: 4),
      ],
    );

    expect(snapshot.weeklyComparison.distanceChangePercent, isNull);
    expect(
      snapshot.weeklyComparison.distanceState,
      AnalyticsChangeState.noBaseline,
    );
  });

  test('builds weekly and monthly trends with zero buckets', () {
    final snapshot = engine.analyze(
      now: now,
      runs: [
        savedRunFixture(completedAt: DateTime(2026, 7, 20), distanceKm: 4),
        savedRunFixture(completedAt: DateTime(2026, 7, 22), distanceKm: 6),
      ],
    );

    expect(snapshot.weeklyDistanceTrend.points, hasLength(7));
    expect(snapshot.weeklyDistanceTrend.points.map((point) => point.value), [
      4,
      0,
      6,
      0,
      0,
      0,
      0,
    ]);
    expect(
      snapshot.monthlyDistanceTrend.points.length,
      greaterThanOrEqualTo(4),
    );
    expect(
      snapshot.activityCountTrend.points.length,
      snapshot.monthlyDistanceTrend.points.length,
    );
  });

  test('pace trend uses latest valid runs chronologically', () {
    final runs = List.generate(
      14,
      (index) => savedRunFixture(
        id: 'run-$index',
        completedAt: DateTime(2026, 7, index + 1),
        distanceKm: index == 2 ? 0 : 5,
        duration: Duration(minutes: 25 + index),
      ),
    );

    final snapshot = engine.analyze(now: now, runs: runs);

    expect(snapshot.paceTrend.points, hasLength(12));
    expect(
      snapshot.paceTrend.points.first.date.isBefore(
        snapshot.paceTrend.points.last.date,
      ),
      isTrue,
    );
    expect(
      snapshot.paceTrend.points.any((point) => point.date.day == 3),
      isFalse,
    );
  });

  test('calculates personal records and leaves split records unavailable', () {
    final snapshot = engine.analyze(
      now: now,
      runs: [
        savedRunFixture(
          id: 'early',
          completedAt: DateTime(2026, 7, 1),
          distanceKm: 10,
          duration: const Duration(minutes: 60),
        ),
        savedRunFixture(
          id: 'tie-later',
          completedAt: DateTime(2026, 7, 2),
          distanceKm: 10,
          duration: const Duration(minutes: 55),
        ),
        savedRunFixture(
          id: 'fast',
          completedAt: DateTime(2026, 7, 3),
          distanceKm: 5,
          duration: const Duration(minutes: 20),
        ),
      ],
    );

    expect(snapshot.personalRecords.longestDistance?.savedRunId, 'early');
    expect(snapshot.personalRecords.longestDuration?.savedRunId, 'early');
    expect(snapshot.personalRecords.fastestAveragePace?.savedRunId, 'fast');
    expect(snapshot.personalRecords.fastestOneKm, isNull);
    expect(snapshot.personalRecords.fastestFiveKm, isNull);
    expect(
      snapshot.personalRecords.mostRunsInOneWeek?.type,
      PersonalRecordType.mostRunsInOneWeek,
    );
  });

  test('classifies simplified non-medical training load', () {
    final snapshot = engine.analyze(
      now: now,
      runs: [
        savedRunFixture(
          completedAt: DateTime(2026, 7, 20),
          distanceKm: 10,
          duration: const Duration(minutes: 50),
        ),
        savedRunFixture(
          id: 'b',
          completedAt: DateTime(2026, 7, 21),
          distanceKm: 12,
          duration: const Duration(minutes: 60),
        ),
      ],
    );

    expect(snapshot.trainingLoad.currentWeeklyLoad, greaterThan(120));
    expect(
      snapshot.trainingLoad.classification,
      TrainingLoadClassification.moderate,
    );
    expect(snapshot.trainingLoad.dailyLoadPoints, hasLength(7));
  });
}
