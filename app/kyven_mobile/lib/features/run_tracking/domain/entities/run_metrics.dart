import 'package:equatable/equatable.dart';

class RunMetrics extends Equatable {
  const RunMetrics({
    required this.elapsed,
    required this.distanceKm,
    required this.currentPace,
    required this.averagePace,
    required this.calories,
    required this.cadence,
    required this.heartRate,
  });

  factory RunMetrics.zero() => const RunMetrics(
    elapsed: Duration.zero,
    distanceKm: 0,
    currentPace: Duration(minutes: 5, seconds: 30),
    averagePace: Duration.zero,
    calories: 0,
    cadence: 0,
    heartRate: 0,
  );

  final Duration averagePace;
  final int cadence;
  final int calories;
  final Duration currentPace;
  final double distanceKm;
  final Duration elapsed;
  final int heartRate;

  RunMetrics copyWith({
    Duration? elapsed,
    double? distanceKm,
    Duration? currentPace,
    Duration? averagePace,
    int? calories,
    int? cadence,
    int? heartRate,
  }) {
    return RunMetrics(
      elapsed: elapsed ?? this.elapsed,
      distanceKm: distanceKm ?? this.distanceKm,
      currentPace: currentPace ?? this.currentPace,
      averagePace: averagePace ?? this.averagePace,
      calories: calories ?? this.calories,
      cadence: cadence ?? this.cadence,
      heartRate: heartRate ?? this.heartRate,
    );
  }

  @override
  List<Object> get props => [
    elapsed,
    distanceKm,
    currentPace,
    averagePace,
    calories,
    cadence,
    heartRate,
  ];
}
