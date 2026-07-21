import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/features/run_tracking/application/location_repository_provider.dart';
import 'package:kyven_mobile/features/run_tracking/application/location_tracking_providers.dart';
import 'package:kyven_mobile/features/run_tracking/application/run_location_state.dart';
import 'package:kyven_mobile/features/run_tracking/application/run_session_providers.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/location_permission_status.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/location_point.dart';
import 'package:kyven_mobile/features/run_tracking/domain/failures/location_failure.dart';

import '../../fakes/fake_location_tracking_repository.dart';

void main() {
  ProviderContainer createContainer(FakeLocationTrackingRepository repository) {
    final container = ProviderContainer(
      overrides: [
        locationTrackingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('permission already granted marks run location ready', () async {
    final repository = FakeLocationTrackingRepository(
      permissionStatus: LocationPermissionStatus.whileInUse,
    );
    final container = createContainer(repository);

    final ready = await container
        .read(runLocationProvider.notifier)
        .ensureReadyForRun();

    expect(ready, isTrue);
    expect(repository.requestPermissionCount, 0);
    expect(container.read(runLocationProvider).isReady, isTrue);
  });

  test('permission requested and granted marks run location ready', () async {
    final repository = FakeLocationTrackingRepository(
      permissionStatus: LocationPermissionStatus.denied,
      requestedPermissionStatus: LocationPermissionStatus.whileInUse,
    );
    final container = createContainer(repository);

    final ready = await container
        .read(runLocationProvider.notifier)
        .ensureReadyForRun();

    expect(ready, isTrue);
    expect(repository.requestPermissionCount, 1);
    expect(
      container.read(runLocationProvider).permissionStatus,
      LocationPermissionStatus.whileInUse,
    );
  });

  test('permission denied surfaces a friendly failure', () async {
    final repository = FakeLocationTrackingRepository(
      permissionStatus: LocationPermissionStatus.denied,
      requestedPermissionStatus: LocationPermissionStatus.denied,
    );
    final container = createContainer(repository);

    final ready = await container
        .read(runLocationProvider.notifier)
        .ensureReadyForRun();

    final state = container.read(runLocationProvider);
    expect(ready, isFalse);
    expect(state.failure?.type, LocationFailureType.permissionDenied);
    expect(state.userMessage, contains('KYVEN needs location'));
  });

  test('permission permanently denied exposes settings state', () async {
    final repository = FakeLocationTrackingRepository(
      permissionStatus: LocationPermissionStatus.deniedForever,
    );
    final container = createContainer(repository);

    final ready = await container
        .read(runLocationProvider.notifier)
        .ensureReadyForRun();

    final state = container.read(runLocationProvider);
    expect(ready, isFalse);
    expect(state.canOpenAppSettings, isTrue);
    await container.read(runLocationProvider.notifier).openAppSettings();
    expect(repository.appSettingsOpened, isTrue);
  });

  test('location services disabled exposes location settings state', () async {
    final repository = FakeLocationTrackingRepository(serviceEnabled: false);
    final container = createContainer(repository);

    final ready = await container
        .read(runLocationProvider.notifier)
        .ensureReadyForRun();

    final state = container.read(runLocationProvider);
    expect(ready, isFalse);
    expect(state.canOpenLocationSettings, isTrue);
    await container.read(runLocationProvider.notifier).openLocationSettings();
    expect(repository.locationSettingsOpened, isTrue);
  });

  test('active run starts one location subscription', () async {
    final repository = FakeLocationTrackingRepository();
    final container = createContainer(repository);

    container.read(runLocationProvider.notifier).startTracking();
    container.read(runLocationProvider.notifier).startTracking();

    expect(repository.totalSubscriptionCount, 1);
    expect(repository.activeSubscriptionCount, 1);
    expect(container.read(runLocationProvider).isTracking, isTrue);
  });

  test(
    'ending a run cancels the subscription through lifecycle listener',
    () async {
      final repository = FakeLocationTrackingRepository();
      final container = createContainer(repository);
      container.read(runLocationLifecycleProvider);

      final locationNotifier = container.read(runLocationProvider.notifier);
      final runNotifier = container.read(runSessionProvider.notifier);
      locationNotifier.startTracking();
      runNotifier.start();
      runNotifier.requestFinish();
      runNotifier.completeFinish();
      await Future<void>.delayed(Duration.zero);

      expect(repository.activeSubscriptionCount, 0);
      expect(repository.stopCount, 1);
      expect(container.read(runLocationProvider).isTracking, isFalse);
    },
  );

  test('discarding a run cancels the subscription through reset', () async {
    final repository = FakeLocationTrackingRepository();
    final container = createContainer(repository);
    container.read(runLocationLifecycleProvider);

    container.read(runLocationProvider.notifier).startTracking();
    container.read(runSessionProvider.notifier).start();
    container.read(runSessionProvider.notifier).reset();
    await Future<void>.delayed(Duration.zero);

    expect(repository.activeSubscriptionCount, 0);
    expect(container.read(runLocationProvider).isTracking, isFalse);
  });

  test('stream errors surface safely', () async {
    final repository = FakeLocationTrackingRepository();
    final container = createContainer(repository);

    container.read(runLocationProvider.notifier).startTracking();
    repository.emitError(
      const LocationFailure(
        type: LocationFailureType.unavailable,
        message: 'Location updates paused unexpectedly.',
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final state = container.read(runLocationProvider);
    expect(state.failure?.type, LocationFailureType.unavailable);
    expect(state.signalStatus, LocationSignalStatus.unavailable);
  });

  test('poor accuracy is reported as weak signal', () async {
    final repository = FakeLocationTrackingRepository();
    final container = createContainer(repository);

    container.read(runLocationProvider.notifier).startTracking();
    repository.emit(
      LocationPoint(
        latitude: 25.2,
        longitude: 55.2,
        accuracy: 80,
        recordedAt: DateTime(2026, 7, 20, 8),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(runLocationProvider).signalStatus,
      LocationSignalStatus.weak,
    );
  });

  test('current position timeout is converted to location failure', () async {
    final repository = FakeLocationTrackingRepository()
      ..currentPositionFailure = const LocationFailure(
        type: LocationFailureType.timeout,
        message: 'GPS is taking longer than expected.',
      );
    final container = createContainer(repository);

    await container.read(runLocationProvider.notifier).refreshCurrentLocation();

    expect(
      container.read(runLocationProvider).failure?.type,
      LocationFailureType.timeout,
    );
  });

  test('repository contract exposes domain location types only', () async {
    final repository = FakeLocationTrackingRepository();

    expect(await repository.getCurrentPosition(), isA<LocationPoint>());
    expect(repository.watchLocation(), isA<Stream<LocationPoint>>());
  });
}
