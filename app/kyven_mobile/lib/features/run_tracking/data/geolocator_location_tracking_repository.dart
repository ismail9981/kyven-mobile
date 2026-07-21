import 'dart:async';

import 'package:geolocator/geolocator.dart' as geo;

import '../../../core/logging/app_logger.dart';
import '../domain/entities/location_permission_status.dart';
import '../domain/entities/location_point.dart';
import '../domain/failures/location_failure.dart';
import '../domain/repositories/location_tracking_repository.dart';

class GeolocatorLocationTrackingRepository
    implements LocationTrackingRepository {
  GeolocatorLocationTrackingRepository({
    geo.LocationSettings? locationSettings,
    this.currentPositionTimeout = const Duration(seconds: 10),
  }) : _locationSettings =
           locationSettings ??
           const geo.LocationSettings(
             accuracy: geo.LocationAccuracy.best,
             distanceFilter: 8,
           );

  final Duration currentPositionTimeout;
  final geo.LocationSettings _locationSettings;

  @override
  Future<bool> isLocationServiceEnabled() {
    return geo.Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    return _mapPermission(await geo.Geolocator.checkPermission());
  }

  @override
  Future<LocationPermissionStatus> requestForegroundPermission() async {
    return _mapPermission(await geo.Geolocator.requestPermission());
  }

  @override
  Future<LocationPoint> getCurrentPosition() async {
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      ).timeout(currentPositionTimeout);
      return _mapPosition(position);
    } on TimeoutException catch (error, stackTrace) {
      AppLogger.instance.d(
        'Current location timed out.',
        error: error,
        stackTrace: stackTrace,
      );
      throw LocationFailure(
        type: LocationFailureType.timeout,
        message: 'GPS is taking longer than expected.',
        cause: error,
      );
    } on geo.LocationServiceDisabledException catch (error, stackTrace) {
      AppLogger.instance.d(
        'Location services are disabled.',
        error: error,
        stackTrace: stackTrace,
      );
      throw LocationFailure(
        type: LocationFailureType.serviceDisabled,
        message: 'Location Services are off.',
        cause: error,
      );
    } on geo.PermissionDeniedException catch (error, stackTrace) {
      AppLogger.instance.d(
        'Location permission denied.',
        error: error,
        stackTrace: stackTrace,
      );
      throw LocationFailure(
        type: LocationFailureType.permissionDenied,
        message: 'Location access is needed to start a GPS run.',
        cause: error,
      );
    } catch (error, stackTrace) {
      AppLogger.instance.d(
        'Location is temporarily unavailable.',
        error: error,
        stackTrace: stackTrace,
      );
      throw LocationFailure(
        type: LocationFailureType.unavailable,
        message: 'Location is unavailable right now.',
        cause: error,
      );
    }
  }

  @override
  Stream<LocationPoint> watchLocation() {
    return geo.Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).map(_mapPosition).handleError((Object error, StackTrace stackTrace) {
      AppLogger.instance.d(
        'Location stream error.',
        error: error,
        stackTrace: stackTrace,
      );
      if (error is geo.LocationServiceDisabledException) {
        throw LocationFailure(
          type: LocationFailureType.serviceDisabled,
          message: 'Location Services are off.',
          cause: error,
        );
      }
      if (error is geo.PermissionDeniedException) {
        throw LocationFailure(
          type: LocationFailureType.permissionDenied,
          message: 'Location access is needed to continue tracking.',
          cause: error,
        );
      }
      throw LocationFailure(
        type: LocationFailureType.unavailable,
        message: 'Location updates paused unexpectedly.',
        cause: error,
      );
    });
  }

  @override
  Future<bool> openAppSettings() {
    return geo.Geolocator.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() {
    return geo.Geolocator.openLocationSettings();
  }

  @override
  Future<void> stop() async {}

  LocationPermissionStatus _mapPermission(geo.LocationPermission permission) {
    return switch (permission) {
      geo.LocationPermission.denied => LocationPermissionStatus.denied,
      geo.LocationPermission.deniedForever =>
        LocationPermissionStatus.deniedForever,
      geo.LocationPermission.whileInUse => LocationPermissionStatus.whileInUse,
      geo.LocationPermission.always => LocationPermissionStatus.always,
      geo.LocationPermission.unableToDetermine =>
        LocationPermissionStatus.unknown,
    };
  }

  LocationPoint _mapPosition(geo.Position position) {
    return LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: _validOptional(position.altitude),
      accuracy: position.accuracy,
      speed: _validOptional(position.speed),
      heading: _validOptional(position.heading),
      recordedAt: position.timestamp,
    );
  }

  double? _validOptional(double value) {
    if (!value.isFinite || value < 0) {
      return null;
    }
    return value;
  }
}
