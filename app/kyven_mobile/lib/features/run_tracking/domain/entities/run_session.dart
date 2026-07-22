import 'package:equatable/equatable.dart';

import 'run_metrics.dart';
import 'run_route.dart';

enum RunSessionStatus { idle, preparing, running, paused, finishing, completed }

class RunSession extends Equatable {
  const RunSession({
    required this.id,
    required this.startedAt,
    required this.metrics,
    required this.route,
  });

  final String id;
  final RunMetrics metrics;
  final RunRoute route;
  final DateTime startedAt;

  RunSession copyWith({RunMetrics? metrics, RunRoute? route}) {
    return RunSession(
      id: id,
      startedAt: startedAt,
      metrics: metrics ?? this.metrics,
      route: route ?? this.route,
    );
  }

  @override
  List<Object> get props => [id, startedAt, metrics, route];
}
