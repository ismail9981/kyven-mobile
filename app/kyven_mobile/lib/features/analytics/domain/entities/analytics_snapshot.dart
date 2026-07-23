import 'package:equatable/equatable.dart';

import 'analytics_comparison.dart';
import 'analytics_trend.dart';
import 'personal_records.dart';
import 'run_period_summary.dart';
import 'training_load_snapshot.dart';

class AnalyticsSnapshot extends Equatable {
  const AnalyticsSnapshot({
    required this.currentWeek,
    required this.previousWeek,
    required this.currentMonth,
    required this.previousMonth,
    required this.weeklyComparison,
    required this.monthlyComparison,
    required this.weeklyDistanceTrend,
    required this.monthlyDistanceTrend,
    required this.paceTrend,
    required this.activityCountTrend,
    required this.personalRecords,
    required this.trainingLoad,
  });

  final AnalyticsTrend activityCountTrend;
  final RunPeriodSummary currentMonth;
  final RunPeriodSummary currentWeek;
  final AnalyticsComparison monthlyComparison;
  final AnalyticsTrend monthlyDistanceTrend;
  final AnalyticsTrend paceTrend;
  final PersonalRecords personalRecords;
  final RunPeriodSummary previousMonth;
  final RunPeriodSummary previousWeek;
  final TrainingLoadSnapshot trainingLoad;
  final AnalyticsComparison weeklyComparison;
  final AnalyticsTrend weeklyDistanceTrend;

  bool get hasRuns =>
      currentWeek.hasRuns ||
      previousWeek.hasRuns ||
      currentMonth.hasRuns ||
      previousMonth.hasRuns ||
      personalRecords.available.isNotEmpty;

  @override
  List<Object> get props => [
    currentWeek,
    previousWeek,
    currentMonth,
    previousMonth,
    weeklyComparison,
    monthlyComparison,
    weeklyDistanceTrend,
    monthlyDistanceTrend,
    paceTrend,
    activityCountTrend,
    personalRecords,
    trainingLoad,
  ];
}
