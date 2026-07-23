import 'package:equatable/equatable.dart';

import 'achievement_definition.dart';
import 'challenge_definition.dart';
import 'challenge_progress.dart';
import 'gamification_profile.dart';

class GamificationUpdateResult extends Equatable {
  const GamificationUpdateResult({
    required this.updatedProfile,
    required this.updatedChallengeProgress,
    required this.newlyCompletedChallenges,
    required this.newlyUnlockedAchievements,
    required this.xpGranted,
    required this.levelBefore,
    required this.levelAfter,
    required this.didLevelUp,
  });

  final bool didLevelUp;
  final int levelAfter;
  final int levelBefore;
  final List<ChallengeDefinition> newlyCompletedChallenges;
  final List<AchievementDefinition> newlyUnlockedAchievements;
  final List<ChallengeProgress> updatedChallengeProgress;
  final GamificationProfile updatedProfile;
  final int xpGranted;

  bool get hasRewards =>
      xpGranted > 0 ||
      newlyCompletedChallenges.isNotEmpty ||
      newlyUnlockedAchievements.isNotEmpty ||
      didLevelUp;

  @override
  List<Object> get props => [
    updatedProfile,
    updatedChallengeProgress,
    newlyCompletedChallenges,
    newlyUnlockedAchievements,
    xpGranted,
    levelBefore,
    levelAfter,
    didLevelUp,
  ];
}
