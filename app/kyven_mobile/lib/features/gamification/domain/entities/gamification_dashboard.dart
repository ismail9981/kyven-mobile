import 'package:equatable/equatable.dart';

import 'achievement_definition.dart';
import 'challenge_definition.dart';
import 'challenge_progress.dart';
import 'gamification_profile.dart';

class GamificationDashboard extends Equatable {
  const GamificationDashboard({
    required this.profile,
    required this.challenges,
    required this.challengeProgress,
    required this.achievements,
  });

  final List<AchievementDefinition> achievements;
  final List<ChallengeProgress> challengeProgress;
  final List<ChallengeDefinition> challenges;
  final GamificationProfile profile;

  @override
  List<Object> get props => [
    profile,
    challenges,
    challengeProgress,
    achievements,
  ];
}
