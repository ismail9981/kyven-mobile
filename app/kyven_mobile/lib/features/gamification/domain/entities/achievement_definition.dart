import 'package:equatable/equatable.dart';

enum AchievementCategory {
  firstRun,
  totalRuns,
  totalDistance,
  singleRunDistance,
  streak,
  training,
  pace,
}

class AchievementDefinition extends Equatable {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.threshold,
    required this.xpReward,
    required this.hiddenUntilUnlocked,
  });

  final AchievementCategory category;
  final String description;
  final bool hiddenUntilUnlocked;
  final String id;
  final double threshold;
  final String title;
  final int xpReward;

  @override
  List<Object> get props => [
    id,
    title,
    description,
    category,
    threshold,
    xpReward,
    hiddenUntilUnlocked,
  ];
}
