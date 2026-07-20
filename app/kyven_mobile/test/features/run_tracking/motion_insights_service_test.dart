import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/motion_insights.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/saved_run.dart';
import 'package:kyven_mobile/features/run_tracking/domain/services/dashboard_message_generator.dart';
import 'package:kyven_mobile/features/run_tracking/domain/services/motion_insights_service.dart';
import 'package:kyven_mobile/features/run_tracking/domain/services/session_name_generator.dart';

void main() {
  const service = MotionInsightsService(weeklyGoalKm: 20);
  final now = DateTime(2026, 7, 22, 10);

  group('MotionInsightsService', () {
    test('calculates today metrics from saved runs only', () {
      final insights = service.calculate([
        _run(
          id: 'today-1',
          completedAt: DateTime(2026, 7, 22, 7),
          distanceKm: 5,
        ),
        _run(
          id: 'today-2',
          completedAt: DateTime(2026, 7, 22, 18),
          distanceKm: 3,
        ),
        _run(id: 'old', completedAt: DateTime(2026, 7, 21, 7), distanceKm: 10),
      ], now: now);

      expect(insights.todayRuns, 2);
      expect(insights.todayDistanceKm, 8);
      expect(insights.todayDuration, const Duration(minutes: 50));
      expect(insights.todayCalories, 544);
    });

    test('calculates weekly and monthly distance', () {
      final insights = service.calculate([
        _run(
          id: 'monday',
          completedAt: DateTime(2026, 7, 20, 7),
          distanceKm: 4,
        ),
        _run(
          id: 'wednesday',
          completedAt: DateTime(2026, 7, 22, 7),
          distanceKm: 6,
        ),
        _run(
          id: 'last-week',
          completedAt: DateTime(2026, 7, 19, 7),
          distanceKm: 8,
        ),
        _run(
          id: 'last-month',
          completedAt: DateTime(2026, 6, 29, 7),
          distanceKm: 9,
        ),
      ], now: now);

      expect(insights.weeklyRuns, 2);
      expect(insights.weeklyDistanceKm, 10);
      expect(insights.monthlyDistanceKm, 18);
      expect(insights.weeklyProgress.map((day) => day.distanceKm), [
        4,
        0,
        6,
        0,
        0,
        0,
        0,
      ]);
    });

    test('calculates streak, longest run, average pace, and duration', () {
      final insights = service.calculate([
        _run(
          id: 'today',
          completedAt: DateTime(2026, 7, 22, 7),
          distanceKm: 5,
          duration: const Duration(minutes: 25),
          averagePace: const Duration(minutes: 5),
        ),
        _run(
          id: 'yesterday',
          completedAt: DateTime(2026, 7, 21, 7),
          distanceKm: 8,
          duration: const Duration(minutes: 48),
          averagePace: const Duration(minutes: 6),
        ),
        _run(
          id: 'older',
          completedAt: DateTime(2026, 7, 19, 7),
          distanceKm: 3,
          duration: const Duration(minutes: 21),
          averagePace: const Duration(minutes: 7),
        ),
      ], now: now);

      expect(insights.currentStreakDays, 2);
      expect(insights.longestRunKm, 8);
      expect(insights.averagePace, const Duration(minutes: 6));
      expect(insights.fastestAveragePace, const Duration(minutes: 5));
      expect(
        insights.averageDuration,
        const Duration(minutes: 31, seconds: 20),
      );
    });

    test('empty history is neutral', () {
      final insights = service.calculate(const [], now: now);

      expect(insights, MotionInsights.empty(weeklyGoalKm: 20));
    });
  });

  group('SessionNameGenerator', () {
    const generator = SessionNameGenerator();

    test('generates deterministic names from run conditions', () {
      final morning = _run(
        completedAt: DateTime(2026, 7, 22, 8),
        averagePace: const Duration(minutes: 5, seconds: 30),
      );
      final sameMorning = _run(
        id: 'same',
        completedAt: DateTime(2026, 7, 22, 8),
        averagePace: const Duration(minutes: 5, seconds: 30),
      );

      expect(generator.generate(morning), 'Morning Run');
      expect(generator.generate(sameMorning), 'Morning Run');
      expect(
        generator.generate(
          _run(
            completedAt: DateTime(2026, 7, 22, 18),
            averagePace: const Duration(minutes: 4, seconds: 50),
          ),
        ),
        'Tempo Session',
      );
      expect(
        generator.generate(
          _run(completedAt: DateTime(2026, 7, 25, 8), distanceKm: 12),
        ),
        'Weekend Long Run',
      );
      expect(
        generator.generate(
          _run(
            completedAt: DateTime(2026, 7, 22, 22),
            distanceKm: 4,
            averagePace: const Duration(minutes: 5, seconds: 45),
          ),
        ),
        'Night Run',
      );
    });
  });

  group('DashboardMessageGenerator', () {
    const generator = DashboardMessageGenerator();

    test('generates contextual messages from insights', () {
      expect(
        generator.generate(MotionInsights.empty(), now: now).subtitle,
        "Ready for today's run?",
      );

      expect(
        generator
            .generate(
              service.calculate([
                _run(completedAt: DateTime(2026, 7, 22, 7)),
              ], now: now),
              now: now,
            )
            .subtitle,
        'One run completed today.',
      );

      expect(
        generator
            .generate(
              service.calculate([
                _run(completedAt: DateTime(2026, 7, 18, 7)),
              ], now: now),
              now: now,
            )
            .title,
        "Let's get moving again.",
      );

      expect(
        generator
            .generate(
              service.calculate([
                _run(completedAt: DateTime(2026, 7, 20, 7), distanceKm: 17.5),
              ], now: now),
              now: now,
            )
            .title,
        "You're almost there.",
      );
    });
  });
}

SavedRun _run({
  String id = 'run',
  DateTime? completedAt,
  double distanceKm = 5,
  Duration duration = const Duration(minutes: 25),
  Duration averagePace = const Duration(minutes: 5),
}) {
  final completed = completedAt ?? DateTime(2026, 7, 22, 7);
  return SavedRun(
    id: id,
    startedAt: completed.subtract(duration),
    completedAt: completed,
    duration: duration,
    distanceKm: distanceKm,
    averagePace: averagePace,
    calories: (distanceKm * 68).round(),
    cadence: 170,
    averageHeartRate: 142,
    routePreview: '',
    achievement: '',
  );
}
