import 'package:equatable/equatable.dart';

import 'run_metrics.dart';

class RunSummary extends Equatable {
  const RunSummary({
    required this.completedAt,
    required this.metrics,
    required this.achievement,
  });

  final String achievement;
  final DateTime completedAt;
  final RunMetrics metrics;

  @override
  List<Object> get props => [completedAt, metrics, achievement];
}
