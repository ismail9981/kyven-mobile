import '../entities/achievement_definition.dart';

abstract final class BuiltInAchievementCatalog {
  static const all = [
    AchievementDefinition(
      id: 'first_run',
      title: 'First Run',
      description: 'Complete the first recorded run.',
      category: AchievementCategory.firstRun,
      threshold: 1,
      xpReward: 100,
      hiddenUntilUnlocked: false,
    ),
    AchievementDefinition(
      id: 'first_5k',
      title: 'First 5K',
      description: 'Complete one run of at least 5 km.',
      category: AchievementCategory.singleRunDistance,
      threshold: 5,
      xpReward: 125,
      hiddenUntilUnlocked: false,
    ),
    AchievementDefinition(
      id: 'ten_runs',
      title: 'Getting Consistent',
      description: 'Complete 10 runs.',
      category: AchievementCategory.totalRuns,
      threshold: 10,
      xpReward: 180,
      hiddenUntilUnlocked: false,
    ),
    AchievementDefinition(
      id: 'distance_25',
      title: '25 Kilometer Club',
      description: 'Reach 25 total kilometers.',
      category: AchievementCategory.totalDistance,
      threshold: 25,
      xpReward: 160,
      hiddenUntilUnlocked: false,
    ),
    AchievementDefinition(
      id: 'distance_50',
      title: '50 Kilometer Club',
      description: 'Reach 50 total kilometers.',
      category: AchievementCategory.totalDistance,
      threshold: 50,
      xpReward: 240,
      hiddenUntilUnlocked: false,
    ),
    AchievementDefinition(
      id: 'streak_3',
      title: 'Three-Day Streak',
      description: 'Record activity on 3 consecutive calendar days.',
      category: AchievementCategory.streak,
      threshold: 3,
      xpReward: 140,
      hiddenUntilUnlocked: false,
    ),
    AchievementDefinition(
      id: 'training_5',
      title: 'Training Commitment',
      description: 'Complete 5 training sessions.',
      category: AchievementCategory.training,
      threshold: 5,
      xpReward: 160,
      hiddenUntilUnlocked: false,
    ),
  ];
}
