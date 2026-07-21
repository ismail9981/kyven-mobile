import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/core/theme/app_theme.dart';
import 'package:kyven_mobile/features/run_tracking/application/run_location_state.dart';
import 'package:kyven_mobile/features/run_tracking/application/run_session_providers.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_session.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/map/run_current_location_marker.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/map/run_map_camera_controller.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/map/run_map_config.dart';

void main() {
  test('map configuration targets OpenStreetMap tiles', () {
    expect(RunMapConfig.openStreetMapTileUrl, contains('openstreetmap.org'));
    expect(RunMapConfig.defaultZoom, greaterThan(0));
    expect(RunMapConfig.maximumFollowFrequency.inMilliseconds, greaterThan(0));
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
}
