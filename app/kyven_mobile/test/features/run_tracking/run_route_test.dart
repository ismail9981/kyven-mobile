import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_route.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_route_point.dart';

void main() {
  RunRoutePoint point({
    required double latitude,
    required double longitude,
    int seconds = 0,
  }) {
    return RunRoutePoint(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime(2026, 7, 21, 7, 0, seconds),
    );
  }

  test('first point creates the first segment', () {
    final route = RunRoute.empty().appendPoint(
      point(latitude: 25.2048, longitude: 55.2708),
    );

    expect(route.segments, hasLength(1));
    expect(route.segments.single.points, hasLength(1));
    expect(route.segments.single.isOpen, isTrue);
  });

  test('multiple points remain ordered', () {
    final first = point(latitude: 25.2048, longitude: 55.2708);
    final second = point(latitude: 25.2049, longitude: 55.2709, seconds: 8);

    final route = RunRoute.empty().appendPoint(first).appendPoint(second);

    expect(route.segments.single.points, [first, second]);
  });

  test('duplicate points are not recorded twice', () {
    final sample = point(latitude: 25.2048, longitude: 55.2708);

    final route = RunRoute.empty().appendPoint(sample).appendPoint(sample);

    expect(route.segments.single.points, hasLength(1));
  });

  test('closing a segment makes the next point start a new segment', () {
    final first = point(latitude: 25.2048, longitude: 55.2708);
    final second = point(latitude: 25.2049, longitude: 55.2709, seconds: 8);

    final route = RunRoute.empty()
        .appendPoint(first)
        .closeActiveSegment()
        .appendPoint(second);

    expect(route.segments, hasLength(2));
    expect(route.segments.first.points, [first]);
    expect(route.segments.last.points, [second]);
    expect(route.segments.first.isOpen, isFalse);
    expect(route.segments.last.isOpen, isTrue);
  });
}
