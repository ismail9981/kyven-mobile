import 'package:equatable/equatable.dart';

import 'run_route_point.dart';

class RunRouteSegment extends Equatable {
  RunRouteSegment({required Iterable<RunRoutePoint> points, this.isOpen = true})
    : points = List.unmodifiable(points);

  final bool isOpen;
  final List<RunRoutePoint> points;

  RunRouteSegment append(RunRoutePoint point) {
    final lastPoint = points.isEmpty ? null : points.last;
    if (lastPoint == point) {
      return this;
    }
    return RunRouteSegment(points: [...points, point], isOpen: isOpen);
  }

  RunRouteSegment close() {
    if (!isOpen) {
      return this;
    }
    return RunRouteSegment(points: points, isOpen: false);
  }

  @override
  List<Object> get props => [points, isOpen];
}
