import '../../../run_tracking/domain/entities/saved_run.dart';
import '../entities/achievement_definition.dart';
import '../entities/challenge_definition.dart';
import '../entities/challenge_progress.dart';
import '../entities/gamification_profile.dart';
import '../entities/gamification_update_result.dart';
import '../entities/unlocked_achievement.dart';
import 'built_in_achievement_catalog.dart';
import 'built_in_challenge_catalog.dart';
import 'challenge_period_calculator.dart';
import 'gamification_xp_policy.dart';
import 'runner_level_calculator.dart';

class GamificationEngine {
  const GamificationEngine({
    this.xpPolicy = const GamificationXpPolicy(),
    this.levelCalculator = const RunnerLevelCalculator(),
    this.periodCalculator = const ChallengePeriodCalculator(),
  });

  final RunnerLevelCalculator levelCalculator;
  final ChallengePeriodCalculator periodCalculator;
  final GamificationXpPolicy xpPolicy;

  List<ChallengeProgress> calculateChallengeProgress({
    required List<SavedRun> runs,
    required GamificationProfile profile,
    required DateTime now,
  }) {
    return BuiltInChallengeCatalog.all
        .map((challenge) => _challengeProgress(challenge, runs, profile, now))
        .toList(growable: false);
  }

  GamificationProfile refreshDerivedProfile({
    required GamificationProfile profile,
    required List<SavedRun> runs,
    required DateTime now,
  }) {
    final level = levelCalculator.calculate(profile.totalXp);
    final streak = _streakStats(runs, now);
    return profile.copyWith(
      currentLevel: level.level,
      xpIntoCurrentLevel: level.xpIntoCurrentLevel,
      xpRequiredForNextLevel: level.xpRequiredForNextLevel,
      currentStreakDays: streak.current,
      longestStreakDays: streak.longest,
    );
  }

  GamificationUpdateResult evaluate({
    required List<SavedRun> runs,
    required GamificationProfile currentProfile,
    required DateTime now,
    Set<String> newlyCompletedTrainingSessionKeys = const {},
  }) {
    final levelBefore = levelCalculator.levelFromXp(currentProfile.totalXp);
    var xpGranted = 0;
    final processedRunIds = {...currentProfile.processedRunIds};
    final processedTrainingKeys = {
      ...currentProfile.processedTrainingSessionKeys,
    };
    final claimedChallengeKeys = {...currentProfile.claimedChallengeRewardKeys};
    final completedChallengeIds = {...currentProfile.completedChallengeIds};
    final unlockedAchievements = [...currentProfile.unlockedAchievements];
    final unlockedIds = unlockedAchievements
        .map((achievement) => achievement.achievementId)
        .toSet();

    for (final run in runs) {
      if (run.isValid && processedRunIds.add(run.id)) {
        xpGranted += xpPolicy.completedValidRunXp;
        if (run.distanceKm >= 5) {
          xpGranted += xpPolicy.fiveKilometerRunBonusXp;
        }
      }
    }

    for (final key in newlyCompletedTrainingSessionKeys) {
      if (key.trim().isNotEmpty && processedTrainingKeys.add(key)) {
        xpGranted += xpPolicy.completedTrainingSessionXp;
      }
    }

    var workingProfile = currentProfile.copyWith(
      processedRunIds: processedRunIds,
      processedTrainingSessionKeys: processedTrainingKeys,
      claimedChallengeRewardKeys: claimedChallengeKeys,
      completedChallengeIds: completedChallengeIds,
      unlockedAchievements: unlockedAchievements,
      totalXp: currentProfile.totalXp + xpGranted,
    );
    workingProfile = refreshDerivedProfile(
      profile: workingProfile,
      runs: runs,
      now: now,
    );

    final challengeProgress = calculateChallengeProgress(
      runs: runs,
      profile: workingProfile,
      now: now,
    );
    final newlyCompletedChallenges = <ChallengeDefinition>[];
    for (final progress in challengeProgress) {
      if (!progress.isCompleted || progress.rewardClaimed) {
        continue;
      }
      final challenge = _challengeById(progress.challengeId);
      if (challenge == null) {
        continue;
      }
      final key = _challengeRewardKey(challenge, progress.periodStart);
      if (claimedChallengeKeys.add(key)) {
        completedChallengeIds.add(challenge.id);
        xpGranted += challenge.xpReward;
        newlyCompletedChallenges.add(challenge);
      }
    }

    workingProfile = workingProfile.copyWith(
      totalXp: currentProfile.totalXp + xpGranted,
      claimedChallengeRewardKeys: claimedChallengeKeys,
      completedChallengeIds: completedChallengeIds,
    );

    final newlyUnlockedAchievements = <AchievementDefinition>[];
    for (final achievement in BuiltInAchievementCatalog.all) {
      if (unlockedIds.contains(achievement.id)) {
        continue;
      }
      if (_isAchievementUnlocked(achievement, runs, workingProfile)) {
        unlockedIds.add(achievement.id);
        xpGranted += achievement.xpReward;
        unlockedAchievements.add(
          UnlockedAchievement(
            achievementId: achievement.id,
            unlockedAt: now,
            xpGranted: achievement.xpReward,
          ),
        );
        newlyUnlockedAchievements.add(achievement);
      }
    }

    final updatedProfile = refreshDerivedProfile(
      profile: workingProfile.copyWith(
        totalXp: currentProfile.totalXp + xpGranted,
        unlockedAchievements: unlockedAchievements,
        claimedChallengeRewardKeys: claimedChallengeKeys,
        completedChallengeIds: completedChallengeIds,
        processedRunIds: processedRunIds,
        processedTrainingSessionKeys: processedTrainingKeys,
      ),
      runs: runs,
      now: now,
    );
    final updatedProgress = calculateChallengeProgress(
      runs: runs,
      profile: updatedProfile,
      now: now,
    );
    final levelAfter = updatedProfile.currentLevel;

    return GamificationUpdateResult(
      updatedProfile: updatedProfile,
      updatedChallengeProgress: updatedProgress,
      newlyCompletedChallenges: newlyCompletedChallenges,
      newlyUnlockedAchievements: newlyUnlockedAchievements,
      xpGranted: xpGranted,
      levelBefore: levelBefore,
      levelAfter: levelAfter,
      didLevelUp: levelAfter > levelBefore,
    );
  }

  ChallengeProgress _challengeProgress(
    ChallengeDefinition challenge,
    List<SavedRun> runs,
    GamificationProfile profile,
    DateTime now,
  ) {
    final period = periodCalculator.periodFor(challenge.period, now);
    final periodRuns = runs
        .where((run) {
          if (challenge.period == ChallengePeriod.lifetime) {
            return run.isValid;
          }
          return run.isValid &&
              !run.completedAt.isBefore(period.start) &&
              run.completedAt.isBefore(period.end);
        })
        .toList(growable: false);
    final value = switch (challenge.category) {
      ChallengeCategory.distance => periodRuns.fold<double>(
        0,
        (sum, run) => sum + run.distanceKm,
      ),
      ChallengeCategory.runCount => periodRuns.length.toDouble(),
      ChallengeCategory.duration => periodRuns.fold<double>(
        0,
        (sum, run) => sum + run.duration.inMinutes,
      ),
      ChallengeCategory.trainingSessions =>
        profile.processedTrainingSessionKeys.length.toDouble(),
      ChallengeCategory.streak => profile.currentStreakDays.toDouble(),
    };
    final key = _challengeRewardKey(challenge, period.start);
    final completed = value >= challenge.targetValue;
    return ChallengeProgress(
      challengeId: challenge.id,
      currentValue: value.clamp(0, challenge.targetValue),
      targetValue: challenge.targetValue,
      periodStart: period.start,
      periodEnd: period.end,
      isCompleted: completed,
      rewardClaimed: profile.claimedChallengeRewardKeys.contains(key),
    );
  }

  bool _isAchievementUnlocked(
    AchievementDefinition achievement,
    List<SavedRun> runs,
    GamificationProfile profile,
  ) {
    return switch (achievement.category) {
      AchievementCategory.firstRun => runs.isNotEmpty,
      AchievementCategory.totalRuns => runs.length >= achievement.threshold,
      AchievementCategory.totalDistance =>
        runs.fold<double>(0, (sum, run) => sum + run.distanceKm) >=
            achievement.threshold,
      AchievementCategory.singleRunDistance => runs.any(
        (run) => run.distanceKm >= achievement.threshold,
      ),
      AchievementCategory.streak =>
        profile.longestStreakDays >= achievement.threshold,
      AchievementCategory.training =>
        profile.processedTrainingSessionKeys.length >= achievement.threshold,
      AchievementCategory.pace => false,
    };
  }

  _StreakStats _streakStats(List<SavedRun> runs, DateTime now) {
    final activeDays =
        runs
            .where((run) => run.isValid)
            .map(
              (run) => DateTime(
                run.completedAt.year,
                run.completedAt.month,
                run.completedAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort();
    if (activeDays.isEmpty) {
      return const _StreakStats(current: 0, longest: 0);
    }

    var longest = 1;
    var currentSequence = 1;
    for (var index = 1; index < activeDays.length; index += 1) {
      final previous = activeDays[index - 1];
      final day = activeDays[index];
      if (day.difference(previous).inDays == 1) {
        currentSequence += 1;
      } else {
        if (currentSequence > longest) {
          longest = currentSequence;
        }
        currentSequence = 1;
      }
    }
    if (currentSequence > longest) {
      longest = currentSequence;
    }

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    var cursor = activeDays.contains(today)
        ? today
        : activeDays.contains(yesterday)
        ? yesterday
        : null;
    var current = 0;
    while (cursor != null && activeDays.contains(cursor)) {
      current += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return _StreakStats(current: current, longest: longest);
  }

  ChallengeDefinition? _challengeById(String id) {
    for (final challenge in BuiltInChallengeCatalog.all) {
      if (challenge.id == id) {
        return challenge;
      }
    }
    return null;
  }

  String _challengeRewardKey(
    ChallengeDefinition challenge,
    DateTime periodStart,
  ) {
    if (!challenge.isRepeatable) {
      return challenge.id;
    }
    return '${challenge.id}:${periodStart.toIso8601String().split('T').first}';
  }
}

class _StreakStats {
  const _StreakStats({required this.current, required this.longest});

  final int current;
  final int longest;
}
