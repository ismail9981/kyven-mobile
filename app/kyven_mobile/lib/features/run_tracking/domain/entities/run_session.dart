import 'package:equatable/equatable.dart';

import 'run_metrics.dart';

enum RunSessionStatus { idle, preparing, running, paused, finishing, completed }

class RunSession extends Equatable {
  const RunSession({
    required this.id,
    required this.startedAt,
    required this.metrics,
  });

  final String id;
  final RunMetrics metrics;
  final DateTime startedAt;

  RunSession copyWith({RunMetrics? metrics}) {
    return RunSession(
      id: id,
      startedAt: startedAt,
      metrics: metrics ?? this.metrics,
    );
  }

  @override
  List<Object> get props => [id, startedAt, metrics];
}
