import 'package:equatable/equatable.dart';

class HomeDashboard extends Equatable {
  const HomeDashboard({
    required this.runnerName,
    required this.greeting,
    required this.motivation,
    required this.weeklyDistance,
    required this.weeklyGoal,
    required this.currentStreak,
    required this.weather,
    required this.todayMetrics,
    required this.weeklyProgress,
    required this.trainingPlan,
    required this.challenges,
    required this.recentActivities,
  });

  final List<ChallengePreview> challenges;
  final int currentStreak;
  final String greeting;
  final String motivation;
  final List<RecentActivity> recentActivities;
  final String runnerName;
  final List<ActivityMetric> todayMetrics;
  final TrainingPlanPreview trainingPlan;
  final String weather;
  final double weeklyDistance;
  final double weeklyGoal;
  final List<WeeklyProgressDay> weeklyProgress;

  double get weeklyProgressRatio => weeklyDistance / weeklyGoal;

  @override
  List<Object> get props => [
    runnerName,
    greeting,
    motivation,
    weeklyDistance,
    weeklyGoal,
    currentStreak,
    weather,
    todayMetrics,
    weeklyProgress,
    trainingPlan,
    challenges,
    recentActivities,
  ];
}

class ActivityMetric extends Equatable {
  const ActivityMetric({
    required this.label,
    required this.value,
    required this.semanticValue,
  });

  final String label;
  final String semanticValue;
  final String value;

  @override
  List<Object> get props => [label, value, semanticValue];
}

class WeeklyProgressDay extends Equatable {
  const WeeklyProgressDay({
    required this.label,
    required this.distance,
    required this.goal,
  });

  final double distance;
  final double goal;
  final String label;

  double get progress => distance / goal;

  @override
  List<Object> get props => [label, distance, goal];
}

class TrainingPlanPreview extends Equatable {
  const TrainingPlanPreview({
    required this.title,
    required this.description,
    required this.duration,
    required this.intensity,
  });

  final String description;
  final String duration;
  final String intensity;
  final String title;

  @override
  List<Object> get props => [title, description, duration, intensity];
}

class ChallengePreview extends Equatable {
  const ChallengePreview({
    required this.title,
    required this.description,
    required this.progress,
  });

  final String description;
  final double progress;
  final String title;

  @override
  List<Object> get props => [title, description, progress];
}

class RecentActivity extends Equatable {
  const RecentActivity({
    required this.title,
    required this.date,
    required this.distance,
    required this.duration,
    required this.pace,
  });

  final String date;
  final String distance;
  final String duration;
  final String pace;
  final String title;

  @override
  List<Object> get props => [title, date, distance, duration, pace];
}
