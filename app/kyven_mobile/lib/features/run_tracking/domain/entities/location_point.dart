import 'package:equatable/equatable.dart';

class LocationPoint extends Equatable {
  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.recordedAt,
    this.altitude,
    this.speed,
    this.heading,
  });

  final double accuracy;
  final double? altitude;
  final double? heading;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? speed;

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    altitude,
    accuracy,
    speed,
    heading,
    recordedAt,
  ];
}
