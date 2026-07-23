import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/core/theme/app_theme.dart';
import 'package:kyven_mobile/features/run_tracking/application/run_location_state.dart';
import 'package:kyven_mobile/features/run_tracking/application/run_session_providers.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_route.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_route_point.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_session.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/map/run_current_location_marker.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/map/run_map_camera_controller.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/map/run_map_config.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/map/run_route_marker.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/map/run_route_polylines.dart';

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

  test('map configuration targets OpenStreetMap tiles', () {
    expect(RunMapConfig.openStreetMapTileUrl, contains('openstreetmap.org'));
    expect(RunMapConfig.defaultZoom, greaterThan(0));
    expect(RunMapConfig.maximumFollowFrequency.inMilliseconds, greaterThan(0));
  });

  test('zero or one route point does not create a polyline', () {
    final emptyPolylines = RunRoutePolylines.polylinesFor(RunRoute.empty());
    final onePointPolylines = RunRoutePolylines.polylinesFor(
      RunRoute.empty().appendPoint(
        point(latitude: 25.2048, longitude: 55.2708),
      ),
    );

    expect(emptyPolylines, isEmpty);
    expect(onePointPolylines, isEmpty);
  });

  test('a route segment with enough points creates one polyline', () {
    final route = RunRoute.empty()
        .appendPoint(point(latitude: 25.2048, longitude: 55.2708))
        .appendPoint(point(latitude: 25.20498, longitude: 55.2708, seconds: 8));

    final polylines = RunRoutePolylines.polylinesFor(route);

    expect(polylines, hasLength(1));
    expect(polylines.single.points, hasLength(2));
    expect(polylines.single.color, RunMapConfig.routeLineColor);
    expect(polylines.single.strokeWidth, RunMapConfig.routeLineWidth);
  });

  test('multiple route segments create separate polylines', () {
    final route = RunRoute.empty()
        .appendPoint(point(latitude: 25.2048, longitude: 55.2708))
        .appendPoint(point(latitude: 25.20498, longitude: 55.2708, seconds: 8))
        .closeActiveSegment()
        .appendPoint(point(latitude: 25.21, longitude: 55.28, seconds: 20))
        .appendPoint(point(latitude: 25.211, longitude: 55.281, seconds: 28));

    final polylines = RunRoutePolylines.polylinesFor(route);

    expect(polylines, hasLength(2));
    expect(
      polylines.first.points.last.latitude,
      isNot(polylines.last.points.first.latitude),
    );
  });

  testWidgets('current location marker renders accessibly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: Center(
            child: RunCurrentLocationMarker(
              signalStatus: LocationSignalStatus.ready,
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Current runner position'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('start and finish route markers render accessibly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: Row(
            children: [RunRouteMarker.start(), RunRouteMarker.finish()],
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Route start marker'), findsOneWidget);
    expect(find.bySemanticsLabel('Route finish marker'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('map camera state does not mutate active run session', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = container.read(runSessionProvider.notifier)..start();
    session.tick(const Duration(seconds: 4));
    final before = container.read(runSessionProvider);

    container
        .read(runMapCameraControllerProvider.notifier)
        .disableFollowForUserGesture();

    final after = container.read(runSessionProvider);
    expect(after.status, RunSessionStatus.running);
    expect(after.metrics, before.metrics);
    container.read(runSessionProvider.notifier).reset();
  });

  test('route updates do not disable camera follow', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    RunRoutePolylines.polylinesFor(
      RunRoute.empty()
          .appendPoint(point(latitude: 25.2048, longitude: 55.2708))
          .appendPoint(
            point(latitude: 25.20498, longitude: 55.2708, seconds: 8),
          ),
    );

    expect(container.read(runMapCameraControllerProvider).isFollowing, isTrue);
  });
}
