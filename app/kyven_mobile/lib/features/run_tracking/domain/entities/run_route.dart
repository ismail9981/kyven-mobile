import 'package:equatable/equatable.dart';

import 'run_route_point.dart';
import 'run_route_segment.dart';

class RunRoute extends Equatable {
  RunRoute({required Iterable<RunRouteSegment> segments})
    : segments = List.unmodifiable(segments);

  factory RunRoute.empty() => RunRoute(segments: const []);

  final List<RunRouteSegment> segments;

  bool get isEmpty => segments.every((segment) => segment.points.isEmpty);

  RunRoute appendPoint(RunRoutePoint point) {
    if (_lastPoint == point) {
      return this;
    }

    if (segments.isEmpty || !segments.last.isOpen) {
      return RunRoute(
        segments: [
          ...segments,
          RunRouteSegment(points: [point]),
        ],
      );
    }

    return RunRoute(
      segments: [
        ...segments.take(segments.length - 1),
        segments.last.append(point),
      ],
    );
  }

  RunRoute closeActiveSegment() {
    if (segments.isEmpty || !segments.last.isOpen) {
      return this;
    }

    return RunRoute(
      segments: [...segments.take(segments.length - 1), segments.last.close()],
    );
  }

  RunRoutePoint? get _lastPoint {
    for (final segment in segments.reversed) {
      if (segment.points.isNotEmpty) {
        return segment.points.last;
      }
    }
    return null;
  }

  @override
  List<Object> get props => [segments];
}
