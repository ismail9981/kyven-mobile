import 'dart:async';

import 'package:kyven_mobile/features/run_tracking/domain/entities/location_permission_status.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/location_point.dart';
import 'package:kyven_mobile/features/run_tracking/domain/failures/location_failure.dart';
import 'package:kyven_mobile/features/run_tracking/domain/repositories/location_tracking_repository.dart';

class FakeLocationTrackingRepository implements LocationTrackingRepository {
  FakeLocationTrackingRepository({
    this.serviceEnabled = true,
    this.permissionStatus = LocationPermissionStatus.whileInUse,
    this.requestedPermissionStatus = LocationPermissionStatus.whileInUse,
    LocationPoint? currentPosition,
  }) : currentPosition =
           currentPosition ??
           LocationPoint(
             latitude: 25.2048,
             longitude: 55.2708,
             accuracy: 12,
             recordedAt: DateTime(2026, 7, 20, 7),
           );

  late final StreamController<LocationPoint> _controller =
      StreamController<LocationPoint>.broadcast(
        onListen: () {
          _activeSubscriptionCount += 1;
          totalSubscriptionCount += 1;
          if (streamFailureOnListen case final failure?) {
            scheduleMicrotask(() => _controller.addError(failure));
          }
        },
        onCancel: () {
          _activeSubscriptionCount -= 1;
        },
      );

  int _activeSubscriptionCount = 0;
  bool appSettingsOpened = false;
  LocationPoint currentPosition;
  LocationFailure? currentPositionFailure;
  bool locationSettingsOpened = false;
  LocationPermissionStatus permissionStatus;
  LocationPermissionStatus requestedPermissionStatus;
  int requestPermissionCount = 0;
  bool serviceEnabled;
  LocationFailure? streamFailureOnListen;
  int stopCount = 0;
  int totalSubscriptionCount = 0;

  int get activeSubscriptionCount => _activeSubscriptionCount;

  @override
  Future<LocationPermissionStatus> checkPermission() async => permissionStatus;

  @override
  Future<LocationPoint> getCurrentPosition() async {
    if (currentPositionFailure case final failure?) {
      throw failure;
    }
    return currentPosition;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<bool> openAppSettings() async {
    appSettingsOpened = true;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    locationSettingsOpened = true;
    return true;
  }

  @override
  Future<LocationPermissionStatus> requestForegroundPermission() async {
    requestPermissionCount += 1;
    permissionStatus = requestedPermissionStatus;
    return permissionStatus;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }

  @override
  Stream<LocationPoint> watchLocation() {
    return _controller.stream;
  }

  void emit(LocationPoint point) {
    _controller.add(point);
  }

  void emitError(Object error) {
    _controller.addError(error);
  }
}
