import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/gps_sample_decision.dart';
import '../domain/entities/location_permission_status.dart';
import '../domain/entities/location_point.dart';
import '../domain/failures/location_failure.dart';
import '../domain/repositories/location_tracking_repository.dart';
import 'location_repository_provider.dart';
import 'run_location_state.dart';
import 'run_session_providers.dart';

class RunLocationController extends Notifier<RunLocationState> {
  static const _weakAccuracyMeters = 35.0;

  late final LocationTrackingRepository _repository;
  // ignore: cancel_subscriptions
  StreamSubscription<LocationPoint>? _subscription;
  var _disposed = false;

  @override
  RunLocationState build() {
    _repository = ref.watch(locationTrackingRepositoryProvider);
    ref.onDispose(() {
      _disposed = true;
      unawaited(_cancelSubscription());
    });
    return const RunLocationState();
  }

  Future<bool> ensureReadyForRun() async {
    if (state.isChecking) {
      return false;
    }

    state = state.copyWith(
      isChecking: true,
      signalStatus: LocationSignalStatus.searching,
      clearFailure: true,
    );

    try {
      final serviceEnabled = await _repository.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _emit(
          state.copyWith(
            serviceEnabled: false,
            isChecking: false,
            signalStatus: LocationSignalStatus.unavailable,
            failure: const LocationFailure(
              type: LocationFailureType.serviceDisabled,
              message: 'Location Services are off.',
            ),
          ),
        );
        return false;
      }

      var permission = await _repository.checkPermission();
      if (permission == LocationPermissionStatus.denied ||
          permission == LocationPermissionStatus.unknown) {
        permission = await _repository.requestForegroundPermission();
      }

      if (permission == LocationPermissionStatus.deniedForever) {
        _emit(
          state.copyWith(
            serviceEnabled: true,
            permissionStatus: permission,
            isChecking: false,
            signalStatus: LocationSignalStatus.unavailable,
            failure: const LocationFailure(
              type: LocationFailureType.permissionDeniedForever,
              message: 'Location access is off.',
            ),
          ),
        );
        return false;
      }

      if (!permission.isGranted) {
        _emit(
          state.copyWith(
            serviceEnabled: true,
            permissionStatus: permission,
            isChecking: false,
            signalStatus: LocationSignalStatus.unavailable,
            failure: const LocationFailure(
              type: LocationFailureType.permissionDenied,
              message: 'Location access is needed to start a GPS run.',
            ),
          ),
        );
        return false;
      }

      _emit(
        state.copyWith(
          serviceEnabled: true,
          permissionStatus: permission,
          isChecking: false,
          signalStatus: LocationSignalStatus.searching,
          clearFailure: true,
        ),
      );
      return true;
    } on LocationFailure catch (failure) {
      _emitFailure(failure);
      return false;
    } catch (error) {
      _emitFailure(
        LocationFailure(
          type: LocationFailureType.unavailable,
          message: 'Location is unavailable right now.',
          cause: error,
        ),
      );
      return false;
    }
  }

  Future<void> refreshCurrentLocation() async {
    try {
      final point = await _repository.getCurrentPosition();
      _emitPoint(point);
    } on LocationFailure catch (failure) {
      _emitFailure(failure);
    } catch (error) {
      _emitFailure(
        LocationFailure(
          type: LocationFailureType.unavailable,
          message: 'Location is unavailable right now.',
          cause: error,
        ),
      );
    }
  }

  void startTracking() {
    if (_subscription != null) {
      return;
    }

    state = state.copyWith(
      isTracking: true,
      signalStatus: LocationSignalStatus.searching,
      clearFailure: true,
    );

    _subscription = _repository.watchLocation().listen(
      _emitPoint,
      onError: (Object error) {
        final failure = error is LocationFailure
            ? error
            : LocationFailure(
                type: LocationFailureType.unavailable,
                message: 'Location updates paused unexpectedly.',
                cause: error,
              );
        _emitFailure(failure, keepTracking: true);
      },
      onDone: () {
        _subscription = null;
        _emit(
          state.copyWith(
            isTracking: false,
            signalStatus: LocationSignalStatus.unavailable,
          ),
        );
      },
    );
  }

  Future<void> stopTracking() async {
    await _cancelSubscription();
    await _repository.stop();
    _emit(
      state.copyWith(
        isTracking: false,
        signalStatus: LocationSignalStatus.unavailable,
      ),
    );
  }

  Future<bool> openAppSettings() => _repository.openAppSettings();

  Future<bool> openLocationSettings() => _repository.openLocationSettings();

  void _emitPoint(LocationPoint point) {
    final decision = ref
        .read(runSessionProvider.notifier)
        .processLocationPoint(point);
    final status = _statusFor(point, decision);
    _emit(
      state.copyWith(
        currentLocation: point,
        signalStatus: status,
        isTracking: _subscription != null,
        clearFailure: true,
      ),
    );
  }

  LocationSignalStatus _statusFor(
    LocationPoint point,
    GpsSampleDecision? decision,
  ) {
    if (decision == null) {
      return point.accuracy > _weakAccuracyMeters
          ? LocationSignalStatus.weak
          : LocationSignalStatus.ready;
    }
    return switch (decision) {
      GpsSampleDecision.accepted => LocationSignalStatus.ready,
      GpsSampleDecision.rejectedAccuracy ||
      GpsSampleDecision.rejectedImpossibleJump => LocationSignalStatus.weak,
      GpsSampleDecision.rejectedTimestamp ||
      GpsSampleDecision.rejectedDuplicate ||
      GpsSampleDecision.rejectedStationaryNoise ||
      GpsSampleDecision.rejectedInsufficientWarmup =>
        state.currentLocation == null
            ? LocationSignalStatus.searching
            : LocationSignalStatus.ready,
    };
  }

  void _emitFailure(LocationFailure failure, {bool keepTracking = false}) {
    _emit(
      state.copyWith(
        isChecking: false,
        isTracking: keepTracking && _subscription != null,
        signalStatus: LocationSignalStatus.unavailable,
        failure: failure,
      ),
    );
  }

  void _emit(RunLocationState next) {
    if (_disposed) {
      return;
    }
    state = next;
  }

  Future<void> _cancelSubscription() async {
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
  }
}
