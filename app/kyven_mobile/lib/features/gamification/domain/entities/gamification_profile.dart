import 'package:equatable/equatable.dart';

import 'unlocked_achievement.dart';

class GamificationProfile extends Equatable {
  const GamificationProfile({
    required this.totalXp,
    required this.currentLevel,
    required this.xpIntoCurrentLevel,
    required this.xpRequiredForNextLevel,
    required this.unlockedAchievements,
    required this.completedChallengeIds,
    required this.claimedChallengeRewardKeys,
    required this.processedRunIds,
    required this.processedTrainingSessionKeys,
    required this.currentStreakDays,
    required this.longestStreakDays,
  });

  factory GamificationProfile.empty() {
    return const GamificationProfile(
      totalXp: 0,
      currentLevel: 1,
      xpIntoCurrentLevel: 0,
      xpRequiredForNextLevel: 250,
      unlockedAchievements: [],
      completedChallengeIds: {},
      claimedChallengeRewardKeys: {},
      processedRunIds: {},
      processedTrainingSessionKeys: {},
      currentStreakDays: 0,
      longestStreakDays: 0,
    );
  }

  final Set<String> claimedChallengeRewardKeys;
  final Set<String> completedChallengeIds;
  final int currentLevel;
  final int currentStreakDays;
  final int longestStreakDays;
  final Set<String> processedRunIds;
  final Set<String> processedTrainingSessionKeys;
  final int totalXp;
  final List<UnlockedAchievement> unlockedAchievements;
  final int xpIntoCurrentLevel;
  final int xpRequiredForNextLevel;

  Set<String> get unlockedAchievementIds => unlockedAchievements
      .map((achievement) => achievement.achievementId)
      .toSet();

  GamificationProfile copyWith({
    int? totalXp,
    int? currentLevel,
    int? xpIntoCurrentLevel,
    int? xpRequiredForNextLevel,
    List<UnlockedAchievement>? unlockedAchievements,
    Set<String>? completedChallengeIds,
    Set<String>? claimedChallengeRewardKeys,
    Set<String>? processedRunIds,
    Set<String>? processedTrainingSessionKeys,
    int? currentStreakDays,
    int? longestStreakDays,
  }) {
    return GamificationProfile(
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      xpIntoCurrentLevel: xpIntoCurrentLevel ?? this.xpIntoCurrentLevel,
      xpRequiredForNextLevel:
          xpRequiredForNextLevel ?? this.xpRequiredForNextLevel,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      completedChallengeIds:
          completedChallengeIds ?? this.completedChallengeIds,
      claimedChallengeRewardKeys:
          claimedChallengeRewardKeys ?? this.claimedChallengeRewardKeys,
      processedRunIds: processedRunIds ?? this.processedRunIds,
      processedTrainingSessionKeys:
          processedTrainingSessionKeys ?? this.processedTrainingSessionKeys,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
    );
  }

  @override
  List<Object> get props => [
    totalXp,
    currentLevel,
    xpIntoCurrentLevel,
    xpRequiredForNextLevel,
    unlockedAchievements,
    completedChallengeIds,
    claimedChallengeRewardKeys,
    processedRunIds,
    processedTrainingSessionKeys,
    currentStreakDays,
    longestStreakDays,
  ];
}
