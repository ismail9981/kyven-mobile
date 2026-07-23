import 'package:equatable/equatable.dart';

import 'analytics_trend.dart';

enum TrainingLoadClassification { low, moderate, high, veryHigh }

class TrainingLoadSnapshot extends Equatable {
  const TrainingLoadSnapshot({
    required this.currentWeeklyLoad,
    required this.previousWeeklyLoad,
    required this.percentageChange,
    required this.classification,
    required this.dailyLoadPoints,
  });

  final TrainingLoadClassification classification;
  final double currentWeeklyLoad;
  final List<AnalyticsDataPoint> dailyLoadPoints;
  final double? percentageChange;
  final double previousWeeklyLoad;

  @override
  List<Object?> get props => [
    currentWeeklyLoad,
    previousWeeklyLoad,
    percentageChange,
    classification,
    dailyLoadPoints,
  ];
}
