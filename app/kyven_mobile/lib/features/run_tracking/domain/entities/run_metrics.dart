import 'package:equatable/equatable.dart';

import 'run_gps_metrics.dart';
import 'run_gps_signal_status.dart';

class RunMetrics extends Equatable {
  const RunMetrics({
    required this.elapsed,
    required this.movingTime,
    required this.pausedTime,
    required this.distanceKm,
    required this.currentPace,
    required this.averagePace,
    required this.currentSpeedMetersPerSecond,
    required this.calories,
    required this.cadence,
    required this.heartRate,
    required this.gps,
  });

  factory RunMetrics.zero() => const RunMetrics(
    elapsed: Duration.zero,
    movingTime: Duration.zero,
    pausedTime: Duration.zero,
    distanceKm: 0,
    currentPace: Duration.zero,
    averagePace: Duration.zero,
    currentSpeedMetersPerSecond: null,
    calories: 0,
    cadence: 0,
    heartRate: 0,
    gps: RunGpsMetrics(
      totalDistanceMeters: 0,
      currentSpeedMetersPerSecond: null,
      smoothedSpeedMetersPerSecond: null,
      averageSpeedMetersPerSecond: null,
      currentPaceSecondsPerKilometer: null,
      averagePaceSecondsPerKilometer: null,
      acceptedPointCount: 0,
      rejectedPointCount: 0,
      gpsSignalStatus: RunGpsSignalStatus.searching,
    ),
  );

  final Duration averagePace;
  final int cadence;
  final int calories;
  final Duration currentPace;
  final double? currentSpeedMetersPerSecond;
  final double distanceKm;
  final Duration elapsed;
  final RunGpsMetrics gps;
  final int heartRate;
  final Duration movingTime;
  final Duration pausedTime;

  RunMetrics copyWith({
    Duration? elapsed,
    Duration? movingTime,
    Duration? pausedTime,
    double? distanceKm,
    Duration? currentPace,
    Duration? averagePace,
    double? currentSpeedMetersPerSecond,
    int? calories,
    int? cadence,
    int? heartRate,
    RunGpsMetrics? gps,
    bool clearCurrentSpeed = false,
  }) {
    return RunMetrics(
      elapsed: elapsed ?? this.elapsed,
      movingTime: movingTime ?? this.movingTime,
      pausedTime: pausedTime ?? this.pausedTime,
      distanceKm: distanceKm ?? this.distanceKm,
      currentPace: currentPace ?? this.currentPace,
      averagePace: averagePace ?? this.averagePace,
      currentSpeedMetersPerSecond: clearCurrentSpeed
          ? null
          : currentSpeedMetersPerSecond ?? this.currentSpeedMetersPerSecond,
      calories: calories ?? this.calories,
      cadence: cadence ?? this.cadence,
      heartRate: heartRate ?? this.heartRate,
      gps: gps ?? this.gps,
    );
  }

  @override
  List<Object?> get props => [
    elapsed,
    movingTime,
    pausedTime,
    distanceKm,
    currentPace,
    averagePace,
    currentSpeedMetersPerSecond,
    calories,
    cadence,
    heartRate,
    gps,
  ];
}
