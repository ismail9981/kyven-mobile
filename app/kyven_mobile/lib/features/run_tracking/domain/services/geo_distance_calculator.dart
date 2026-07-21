import 'dart:math' as math;

import '../entities/location_point.dart';

class GeoDistanceCalculator {
  const GeoDistanceCalculator();

  static const _earthRadiusMeters = 6371008.8;

  double distanceMeters(LocationPoint from, LocationPoint to) {
    if (from.latitude == to.latitude && from.longitude == to.longitude) {
      return 0;
    }

    final fromLatitude = _radians(from.latitude);
    final toLatitude = _radians(to.latitude);
    final latitudeDelta = _radians(to.latitude - from.latitude);
    final longitudeDelta = _radians(to.longitude - from.longitude);

    final haversine =
        math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(fromLatitude) *
            math.cos(toLatitude) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    final angle =
        2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
    return _earthRadiusMeters * angle;
  }

  double _radians(double degrees) => degrees * math.pi / 180;
}
