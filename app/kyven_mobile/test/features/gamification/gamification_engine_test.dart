import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/features/gamification/domain/entities/challenge_definition.dart';
import 'package:kyven_mobile/features/gamification/domain/entities/gamification_profile.dart';
import 'package:kyven_mobile/features/gamification/domain/services/challenge_period_calculator.dart';
import 'package:kyven_mobile/features/gamification/domain/services/gamification_engine.dart';
import 'package:kyven_mobile/features/gamification/domain/services/runner_level_calculator.dart';

import '../../helpers/test_app.dart';

void main() {
  const levelCalculator = RunnerLevelCalculator();
  const periodCalculator = ChallengePeriodCalculator();
  const engine = GamificationEngine();

  test('level thresholds and XP progress are deterministic', () {
    expect(levelCalculator.calculate(0).level, 1);
    expect(levelCalculator.calculate(250).level, 2);
    expect(levelCalculator.calculate(600).level, 3);
    final snapshot = levelCalculator.calculate(350);
    expect(snapshot.xpIntoCurrentLevel, 100);
    expect(snapshot.xpRequiredForNextLevel, 350);
    expect(snapshot.progressFraction, closeTo(100 / 350, 0.001));
  });

  test(
    'weekly periods start on Monday and monthly periods use calendar months',
    () {
      final weekly = periodCalculator.periodFor(
        ChallengePeriod.weekly,
        DateTime(2026, 7, 22),
      );
      expect(weekly.start, DateTime(2026, 7, 20));
      expect(weekly.end, DateTime(2026, 7, 27));

      final monthly = periodCalculator.periodFor(
        ChallengePeriod.monthly,
        DateTime(2026, 7, 22),
      );
      expect(monthly.start, DateTime(2026, 7));
      expect(monthly.end, DateTime(2026, 8));
    },
  );

  test('calculates distance, run-count, duration, and training progress', () {
    final now = DateTime(2026, 7, 22, 12);
    final profile = GamificationProfile.empty().copyWith(
      processedTrainingSessionKeys: {'p:w1-d1', 'p:w1-d2'},
    );
    final progress = engine.calculateChallengeProgress(
      runs: [
        savedRunFixture(
          id: 'a',
          completedAt: DateTime(2026, 7, 20),
          distanceKm: 2,
          duration: const Duration(minutes: 20),
        ),
        savedRunFixture(
          id: 'b',
          completedAt: DateTime(2026, 7, 21),
          distanceKm: 3.5,
          duration: const Duration(minutes: 35),
        ),
      ],
      profile: profile,
      now: now,
    );
    double value(String id) =>
        progress.singleWhere((item) => item.challengeId == id).currentValue;
    expect(value('weekly_5k'), 5);
    expect(value('weekly_3_runs'), 2);
    expect(value('weekly_60_minutes'), 55);
    expect(value('monthly_4_training'), 2);
  });

  test('grants run, challenge, and achievement XP once', () {
    final run = savedRunFixture(
      id: 'run-1',
      completedAt: DateTime(2026, 7, 20),
      distanceKm: 5,
      duration: const Duration(minutes: 30),
    );
    final first = engine.evaluate(
      runs: [run],
      currentProfile: GamificationProfile.empty(),
      now: DateTime(2026, 7, 20, 10),
    );
    expect(first.xpGranted, greaterThan(0));
    expect(
      first.newlyUnlockedAchievements.map((item) => item.id),
      contains('first_run'),
    );
    expect(
      first.newlyUnlockedAchievements.map((item) => item.id),
      contains('first_5k'),
    );
    expect(
      first.newlyCompletedChallenges.map((item) => item.id),
      contains('weekly_5k'),
    );

    final second = engine.evaluate(
      runs: [run],
      currentProfile: first.updatedProfile,
      now: DateTime(2026, 7, 20, 10),
    );
    expect(second.xpGranted, 0);
    expect(second.newlyCompletedChallenges, isEmpty);
    expect(second.newlyUnlockedAchievements, isEmpty);
  });

  test('repeatable challenge rewards are period-specific', () {
    final first = engine.evaluate(
      runs: [
        savedRunFixture(
          id: 'week-1',
          completedAt: DateTime(2026, 7, 20),
          distanceKm: 5,
        ),
      ],
      currentProfile: GamificationProfile.empty(),
      now: DateTime(2026, 7, 20),
    );
    final second = engine.evaluate(
      runs: [
        savedRunFixture(
          id: 'week-1',
          completedAt: DateTime(2026, 7, 20),
          distanceKm: 5,
        ),
        savedRunFixture(
          id: 'week-2',
          completedAt: DateTime(2026, 7, 27),
          distanceKm: 5,
        ),
      ],
      currentProfile: first.updatedProfile,
      now: DateTime(2026, 7, 27),
    );
    expect(
      second.newlyCompletedChallenges.map((item) => item.id),
      contains('weekly_5k'),
    );
  });

  test(
    'streaks normalize multiple same-day runs and handle broken streaks',
    () {
      final profile = engine.refreshDerivedProfile(
        profile: GamificationProfile.empty(),
        runs: [
          savedRunFixture(id: 'a', completedAt: DateTime(2026, 7, 18)),
          savedRunFixture(id: 'b', completedAt: DateTime(2026, 7, 20)),
          savedRunFixture(id: 'c', completedAt: DateTime(2026, 7, 21)),
          savedRunFixture(id: 'd', completedAt: DateTime(2026, 7, 21, 18)),
        ],
        now: DateTime(2026, 7, 22),
      );
      expect(profile.currentStreakDays, 2);
      expect(profile.longestStreakDays, 2);
    },
  );

  test(
    'training completion grants XP once and unlocks training achievement',
    () {
      var profile = GamificationProfile.empty();
      for (var i = 1; i <= 5; i += 1) {
        final result = engine.evaluate(
          runs: const [],
          currentProfile: profile,
          now: DateTime(2026, 7, 22),
          newlyCompletedTrainingSessionKeys: {'plan:w1-d$i'},
        );
        profile = result.updatedProfile;
      }
      expect(profile.processedTrainingSessionKeys, hasLength(5));
      expect(profile.unlockedAchievementIds, contains('training_5'));
    },
  );
}
