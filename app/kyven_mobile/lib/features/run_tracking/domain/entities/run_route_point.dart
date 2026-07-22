import 'package:equatable/equatable.dart';

import 'location_point.dart';

class RunRoutePoint extends Equatable {
  const RunRoutePoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory RunRoutePoint.fromLocationPoint(LocationPoint point) {
    return RunRoutePoint(
      latitude: point.latitude,
      longitude: point.longitude,
      timestamp: point.recordedAt,
    );
  }

  final double latitude;
  final double longitude;
  final DateTime timestamp;

  @override
  List<Object> get props => [latitude, longitude, timestamp];
}
