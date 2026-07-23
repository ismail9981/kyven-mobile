import 'package:equatable/equatable.dart';

import 'analytics_period.dart';

class RunPeriodSummary extends Equatable {
  const RunPeriodSummary({
    required this.period,
    required this.totalDistanceKm,
    required this.totalDuration,
    required this.totalCalories,
    required this.runCount,
    required this.averageDistanceKm,
    required this.averagePace,
    required this.longestRunDistanceKm,
    required this.longestRunDuration,
  });

  factory RunPeriodSummary.empty(AnalyticsPeriod period) {
    return RunPeriodSummary(
      period: period,
      totalDistanceKm: 0,
      totalDuration: Duration.zero,
      totalCalories: 0,
      runCount: 0,
      averageDistanceKm: 0,
      averagePace: null,
      longestRunDistanceKm: 0,
      longestRunDuration: Duration.zero,
    );
  }

  final double averageDistanceKm;
  final Duration? averagePace;
  final double longestRunDistanceKm;
  final Duration longestRunDuration;
  final AnalyticsPeriod period;
  final int runCount;
  final int totalCalories;
  final double totalDistanceKm;
  final Duration totalDuration;

  bool get hasRuns => runCount > 0;

  @override
  List<Object?> get props => [
    period,
    totalDistanceKm,
    totalDuration,
    totalCalories,
    runCount,
    averageDistanceKm,
    averagePace,
    longestRunDistanceKm,
    longestRunDuration,
  ];
}
