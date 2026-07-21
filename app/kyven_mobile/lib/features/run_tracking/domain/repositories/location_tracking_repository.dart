import '../entities/location_permission_status.dart';
import '../entities/location_point.dart';

abstract interface class LocationTrackingRepository {
  Future<bool> isLocationServiceEnabled();

  Future<LocationPermissionStatus> checkPermission();

  Future<LocationPermissionStatus> requestForegroundPermission();

  Future<LocationPoint> getCurrentPosition();

  Stream<LocationPoint> watchLocation();

  Future<bool> openAppSettings();

  Future<bool> openLocationSettings();

  Future<void> stop();
}
