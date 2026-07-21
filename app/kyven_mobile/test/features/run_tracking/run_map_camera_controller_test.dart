import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/location_point.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/map/run_map_camera_controller.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/map/run_map_config.dart';

void main() {
  LocationPoint point({
    required double latitude,
    required double longitude,
    int seconds = 0,
  }) {
    return LocationPoint(
      latitude: latitude,
      longitude: longitude,
      accuracy: 8,
      recordedAt: DateTime(2026, 7, 21, 7, 0, seconds),
    );
  }

  ProviderContainer createContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('camera follows accepted location updates', () {
    final container = createContainer();
    final notifier = container.read(runMapCameraControllerProvider.notifier);

    notifier.updateLocation(
      point(latitude: 25.2048, longitude: 55.2708),
      now: DateTime(2026, 7, 21, 7),
    );

    final state = container.read(runMapCameraControllerProvider);
    expect(state.isFollowing, isTrue);
    expect(state.target.latitude, closeTo(25.2048, 0.000001));
    expect(state.target.longitude, closeTo(55.2708, 0.000001));
  });

  test('camera follow updates are throttled', () {
    final container = createContainer();
    final notifier = container.read(runMapCameraControllerProvider.notifier);
    final now = DateTime(2026, 7, 21, 7);

    notifier.updateLocation(
      point(latitude: 25.2048, longitude: 55.2708),
      now: now,
    );
    notifier.updateLocation(
      point(latitude: 25.21, longitude: 55.28),
      now: now.add(RunMapConfig.maximumFollowFrequency ~/ 2),
    );

    final state = container.read(runMapCameraControllerProvider);
    expect(state.target.latitude, closeTo(25.2048, 0.000001));
    expect(state.target.longitude, closeTo(55.2708, 0.000001));
  });

  test('manual pan disables auto-follow', () {
    final container = createContainer();
    final notifier = container.read(runMapCameraControllerProvider.notifier);

    notifier.disableFollowForUserGesture();

    expect(container.read(runMapCameraControllerProvider).isFollowing, isFalse);
  });

  test('restore follow re-centers on current location', () {
    final container = createContainer();
    final notifier = container.read(runMapCameraControllerProvider.notifier);
    final location = point(latitude: 25.22, longitude: 55.29);

    notifier.disableFollowForUserGesture();
    notifier.restoreFollow(location, now: DateTime(2026, 7, 21, 7));

    final state = container.read(runMapCameraControllerProvider);
    expect(state.isFollowing, isTrue);
    expect(state.target.latitude, closeTo(location.latitude, 0.000001));
    expect(state.target.longitude, closeTo(location.longitude, 0.000001));
  });
}
