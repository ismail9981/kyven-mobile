import 'package:equatable/equatable.dart';

import 'location_point.dart';
import 'run_gps_signal_status.dart';

class RunGpsMetrics extends Equatable {
  const RunGpsMetrics({
    required this.totalDistanceMeters,
    required this.currentSpeedMetersPerSecond,
    required this.smoothedSpeedMetersPerSecond,
    required this.averageSpeedMetersPerSecond,
    required this.currentPaceSecondsPerKilometer,
    required this.averagePaceSecondsPerKilometer,
    required this.acceptedPointCount,
    required this.rejectedPointCount,
    required this.gpsSignalStatus,
    this.lastAcceptedPoint,
    this.lastUpdatedAt,
  });

  factory RunGpsMetrics.zero() => const RunGpsMetrics(
    totalDistanceMeters: 0,
    currentSpeedMetersPerSecond: null,
    smoothedSpeedMetersPerSecond: null,
    averageSpeedMetersPerSecond: null,
    currentPaceSecondsPerKilometer: null,
    averagePaceSecondsPerKilometer: null,
    acceptedPointCount: 0,
    rejectedPointCount: 0,
    gpsSignalStatus: RunGpsSignalStatus.searching,
  );

  final int acceptedPointCount;
  final double? averagePaceSecondsPerKilometer;
  final double? averageSpeedMetersPerSecond;
  final double? currentPaceSecondsPerKilometer;
  final double? currentSpeedMetersPerSecond;
  final RunGpsSignalStatus gpsSignalStatus;
  final LocationPoint? lastAcceptedPoint;
  final DateTime? lastUpdatedAt;
  final int rejectedPointCount;
  final double? smoothedSpeedMetersPerSecond;
  final double totalDistanceMeters;

  RunGpsMetrics copyWith({
    double? totalDistanceMeters,
    double? currentSpeedMetersPerSecond,
    double? smoothedSpeedMetersPerSecond,
    double? averageSpeedMetersPerSecond,
    double? currentPaceSecondsPerKilometer,
    double? averagePaceSecondsPerKilometer,
    int? acceptedPointCount,
    int? rejectedPointCount,
    RunGpsSignalStatus? gpsSignalStatus,
    LocationPoint? lastAcceptedPoint,
    DateTime? lastUpdatedAt,
    bool clearCurrentSpeed = false,
    bool clearSmoothedSpeed = false,
    bool clearAverageSpeed = false,
    bool clearCurrentPace = false,
    bool clearAveragePace = false,
    bool clearLastAcceptedPoint = false,
    bool clearLastUpdatedAt = false,
  }) {
    return RunGpsMetrics(
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      currentSpeedMetersPerSecond: clearCurrentSpeed
          ? null
          : currentSpeedMetersPerSecond ?? this.currentSpeedMetersPerSecond,
      smoothedSpeedMetersPerSecond: clearSmoothedSpeed
          ? null
          : smoothedSpeedMetersPerSecond ?? this.smoothedSpeedMetersPerSecond,
      averageSpeedMetersPerSecond: clearAverageSpeed
          ? null
          : averageSpeedMetersPerSecond ?? this.averageSpeedMetersPerSecond,
      currentPaceSecondsPerKilometer: clearCurrentPace
          ? null
          : currentPaceSecondsPerKilometer ??
                this.currentPaceSecondsPerKilometer,
      averagePaceSecondsPerKilometer: clearAveragePace
          ? null
          : averagePaceSecondsPerKilometer ??
                this.averagePaceSecondsPerKilometer,
      acceptedPointCount: acceptedPointCount ?? this.acceptedPointCount,
      rejectedPointCount: rejectedPointCount ?? this.rejectedPointCount,
      gpsSignalStatus: gpsSignalStatus ?? this.gpsSignalStatus,
      lastAcceptedPoint: clearLastAcceptedPoint
          ? null
          : lastAcceptedPoint ?? this.lastAcceptedPoint,
      lastUpdatedAt: clearLastUpdatedAt
          ? null
          : lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  @override
  List<Object?> get props => [
    totalDistanceMeters,
    currentSpeedMetersPerSecond,
    smoothedSpeedMetersPerSecond,
    averageSpeedMetersPerSecond,
    currentPaceSecondsPerKilometer,
    averagePaceSecondsPerKilometer,
    acceptedPointCount,
    rejectedPointCount,
    gpsSignalStatus,
    lastAcceptedPoint,
    lastUpdatedAt,
  ];
}
