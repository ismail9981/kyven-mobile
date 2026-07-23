import 'package:equatable/equatable.dart';

import 'run_period_summary.dart';

enum AnalyticsChangeState { available, bothZero, noBaseline, missingCurrent }

class AnalyticsComparison extends Equatable {
  const AnalyticsComparison({
    required this.current,
    required this.previous,
    required this.distanceChangePercent,
    required this.durationChangePercent,
    required this.runCountChangePercent,
    required this.paceImprovementPercent,
    required this.distanceState,
    required this.durationState,
    required this.runCountState,
    required this.paceState,
  });

  final RunPeriodSummary current;
  final double? distanceChangePercent;
  final AnalyticsChangeState distanceState;
  final double? durationChangePercent;
  final AnalyticsChangeState durationState;
  final double? paceImprovementPercent;
  final AnalyticsChangeState paceState;
  final RunPeriodSummary previous;
  final double? runCountChangePercent;
  final AnalyticsChangeState runCountState;

  bool get hasDistanceComparison =>
      distanceState == AnalyticsChangeState.available;

  bool get hasDurationComparison =>
      durationState == AnalyticsChangeState.available;

  bool get hasRunCountComparison =>
      runCountState == AnalyticsChangeState.available;

  bool get hasPaceComparison => paceState == AnalyticsChangeState.available;

  @override
  List<Object?> get props => [
    current,
    previous,
    distanceChangePercent,
    durationChangePercent,
    runCountChangePercent,
    paceImprovementPercent,
    distanceState,
    durationState,
    runCountState,
    paceState,
  ];
}
