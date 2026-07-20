import 'package:equatable/equatable.dart';

import 'saved_run.dart';

class MotionInsights extends Equatable {
  const MotionInsights({
    required this.totalRuns,
    required this.weeklyRuns,
    required this.todayRuns,
    required this.todayDistanceKm,
    required this.todayDuration,
    required this.todayCalories,
    required this.weeklyDistanceKm,
    required this.monthlyDistanceKm,
    required this.totalDistanceKm,
    required this.totalDuration,
    required this.currentStreakDays,
    required this.longestRunKm,
    required this.averagePace,
    required this.fastestAveragePace,
    required this.averageDuration,
    required this.latestRunDate,
    required this.latestRuns,
    required this.weeklyProgress,
    required this.weeklyGoalKm,
  });

  factory MotionInsights.empty({double weeklyGoalKm = 20}) => MotionInsights(
    totalRuns: 0,
    weeklyRuns: 0,
    todayRuns: 0,
    todayDistanceKm: 0,
    todayDuration: Duration.zero,
    todayCalories: 0,
    weeklyDistanceKm: 0,
    monthlyDistanceKm: 0,
    totalDistanceKm: 0,
    totalDuration: Duration.zero,
    currentStreakDays: 0,
    longestRunKm: 0,
    averagePace: null,
    fastestAveragePace: null,
    averageDuration: null,
    latestRunDate: null,
    latestRuns: const [],
    weeklyProgress: _emptyWeek,
    weeklyGoalKm: weeklyGoalKm,
  );

  static const _emptyWeek = [
    MotionWeekDay(label: 'M', distanceKm: 0, goalKm: 1),
    MotionWeekDay(label: 'T', distanceKm: 0, goalKm: 1),
    MotionWeekDay(label: 'W', distanceKm: 0, goalKm: 1),
    MotionWeekDay(label: 'T', distanceKm: 0, goalKm: 1),
    MotionWeekDay(label: 'F', distanceKm: 0, goalKm: 1),
    MotionWeekDay(label: 'S', distanceKm: 0, goalKm: 1),
    MotionWeekDay(label: 'S', distanceKm: 0, goalKm: 1),
  ];

  final Duration? averageDuration;
  final Duration? averagePace;
  final int currentStreakDays;
  final Duration? fastestAveragePace;
  final DateTime? latestRunDate;
  final List<SavedRun> latestRuns;
  final double longestRunKm;
  final double monthlyDistanceKm;
  final int todayCalories;
  final double todayDistanceKm;
  final Duration todayDuration;
  final int todayRuns;
  final double totalDistanceKm;
  final Duration totalDuration;
  final int totalRuns;
  final double weeklyDistanceKm;
  final double weeklyGoalKm;
  final List<MotionWeekDay> weeklyProgress;
  final int weeklyRuns;

  bool get hasRuns => totalRuns > 0;

  bool get hasRunsToday => todayRuns > 0;

  double get weeklyGoalProgress => weeklyGoalKm <= 0
      ? 0
      : (weeklyDistanceKm / weeklyGoalKm).clamp(0, 1).toDouble();

  @override
  List<Object?> get props => [
    totalRuns,
    weeklyRuns,
    todayRuns,
    todayDistanceKm,
    todayDuration,
    todayCalories,
    weeklyDistanceKm,
    monthlyDistanceKm,
    totalDistanceKm,
    totalDuration,
    currentStreakDays,
    longestRunKm,
    averagePace,
    fastestAveragePace,
    averageDuration,
    latestRunDate,
    latestRuns,
    weeklyProgress,
    weeklyGoalKm,
  ];
}

class MotionWeekDay extends Equatable {
  const MotionWeekDay({
    required this.label,
    required this.distanceKm,
    required this.goalKm,
  });

  final double distanceKm;
  final double goalKm;
  final String label;

  double get progress =>
      goalKm <= 0 ? 0 : (distanceKm / goalKm).clamp(0, 1).toDouble();

  @override
  List<Object> get props => [label, distanceKm, goalKm];
}

class DashboardMessage extends Equatable {
  const DashboardMessage({required this.title, required this.subtitle});

  final String subtitle;
  final String title;

  @override
  List<Object> get props => [title, subtitle];
}
