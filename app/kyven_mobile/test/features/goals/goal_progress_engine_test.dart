import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/features/goals/domain/entities/personal_goal.dart';
import 'package:kyven_mobile/features/goals/domain/services/goal_period_service.dart';
import 'package:kyven_mobile/features/goals/domain/services/goal_progress_engine.dart';

import '../../helpers/test_app.dart';

void main() {
  const periodService = GoalPeriodService();
  const engine = GoalProgressEngine();
  final now = DateTime(2026, 7, 22, 12);

  group('GoalPeriodService', () {
    test('weekly period starts Monday and excludes following Monday', () {
      final period = periodService.weekly(DateTime(2026, 7, 22));

      expect(period.startAt, DateTime(2026, 7, 20));
      expect(period.endAt, DateTime(2026, 7, 27));
    });

    test('monthly period handles previous and next year boundaries', () {
      final december = periodService.monthly(DateTime(2026, 12, 20));
      final january = periodService.monthly(DateTime(2027, 1, 4));

      expect(december.startAt, DateTime(2026, 12));
      expect(december.endAt, DateTime(2027, 1));
      expect(january.startAt, DateTime(2027, 1));
      expect(january.endAt, DateTime(2027, 2));
    });

    test('custom end date is converted to exclusive next day', () {
      final period = periodService.custom(
        selectedStart: DateTime(2026, 7, 10, 14),
        selectedEnd: DateTime(2026, 7, 12, 9),
      );

      expect(period.startAt, DateTime(2026, 7, 10));
      expect(period.endAt, DateTime(2026, 7, 13));
    });

    test('invalid custom range is rejected', () {
      expect(
        () => periodService.custom(
          selectedStart: DateTime(2026, 7, 12),
          selectedEnd: DateTime(2026, 7, 11),
        ),
        throwsA(isA<GoalPeriodException>()),
      );
    });
  });

  group('GoalProgressEngine', () {
    test('empty run history leaves active zero progress', () {
      final result = engine.evaluate(
        goal: personalGoalFixture(),
        runs: const [],
        now: now,
      );

      expect(result.progress.currentValue, 0);
      expect(result.progress.progressFraction, 0);
      expect(result.progress.remainingValue, 10);
      expect(result.progress.status, GoalStatus.active);
    });

    test('aggregates distance, run count, duration, and calories', () {
      final runs = [
        savedRunFixture(completedAt: DateTime(2026, 7, 20), distanceKm: 4),
        savedRunFixture(
          id: 'b',
          completedAt: DateTime(2026, 7, 21),
          distanceKm: 6,
          duration: const Duration(minutes: 40),
          calories: 500,
        ),
      ];

      expect(
        engine
            .evaluate(goal: personalGoalFixture(), runs: runs, now: now)
            .progress
            .currentValue,
        10,
      );
      expect(
        engine
            .evaluate(
              goal: personalGoalFixture(
                type: GoalType.runCount,
                unit: GoalUnit.runs,
                targetValue: 3,
              ),
              runs: runs,
              now: now,
            )
            .progress
            .currentValue,
        2,
      );
      expect(
        engine
            .evaluate(
              goal: personalGoalFixture(
                type: GoalType.duration,
                unit: GoalUnit.minutes,
                targetValue: 90,
              ),
              runs: runs,
              now: now,
            )
            .progress
            .currentValue,
        68,
      );
      expect(
        engine
            .evaluate(
              goal: personalGoalFixture(
                type: GoalType.calories,
                unit: GoalUnit.calories,
                targetValue: 1000,
              ),
              runs: runs,
              now: now,
            )
            .progress
            .currentValue,
        854,
      );
    });

    test('includes run at start and excludes run at end', () {
      final result = engine.evaluate(
        goal: personalGoalFixture(),
        runs: [
          savedRunFixture(completedAt: DateTime(2026, 7, 20), distanceKm: 4),
          savedRunFixture(
            id: 'end',
            completedAt: DateTime(2026, 7, 27),
            distanceKm: 100,
          ),
          savedRunFixture(
            id: 'before',
            completedAt: DateTime(2026, 7, 19, 23, 59),
            distanceKm: 100,
          ),
        ],
        now: now,
      );

      expect(result.progress.currentValue, 4);
    });

    test('completion is clamped and detected once', () {
      final active = engine.evaluate(
        goal: personalGoalFixture(targetValue: 5),
        runs: [
          savedRunFixture(completedAt: DateTime(2026, 7, 21), distanceKm: 8),
        ],
        now: now,
      );
      final stable = engine.evaluate(
        goal: active.goal,
        runs: [
          savedRunFixture(completedAt: DateTime(2026, 7, 21), distanceKm: 8),
        ],
        now: now,
      );

      expect(active.progress.progressFraction, 1);
      expect(active.progress.remainingValue, 0);
      expect(active.progress.status, GoalStatus.completed);
      expect(active.didBecomeCompleted, isTrue);
      expect(stable.didBecomeCompleted, isFalse);
    });

    test('expired incomplete and archived statuses remain stable', () {
      final expired = engine.evaluate(
        goal: personalGoalFixture(endAt: DateTime(2026, 7, 21)),
        runs: const [],
        now: now,
      );
      final archived = engine.evaluate(
        goal: personalGoalFixture(status: GoalStatus.archived),
        runs: [
          savedRunFixture(completedAt: DateTime(2026, 7, 21), distanceKm: 20),
        ],
        now: now,
      );

      expect(expired.progress.status, GoalStatus.expired);
      expect(expired.didBecomeExpired, isTrue);
      expect(archived.progress.status, GoalStatus.archived);
    });

    test('on-track rule handles schedule states safely', () {
      final ahead = engine.evaluate(
        goal: personalGoalFixture(targetValue: 10),
        runs: [
          savedRunFixture(completedAt: DateTime(2026, 7, 21), distanceKm: 5),
        ],
        now: DateTime(2026, 7, 21),
      );
      final behind = engine.evaluate(
        goal: personalGoalFixture(targetValue: 10),
        runs: [
          savedRunFixture(completedAt: DateTime(2026, 7, 21), distanceKm: 1),
        ],
        now: DateTime(2026, 7, 24),
      );
      final before = engine.evaluate(
        goal: personalGoalFixture(startAt: DateTime(2026, 7, 25)),
        runs: const [],
        now: now,
      );

      expect(ahead.progress.isOnTrack, isTrue);
      expect(behind.progress.isOnTrack, isFalse);
      expect(before.progress.isOnTrack, isTrue);
    });
  });
}
