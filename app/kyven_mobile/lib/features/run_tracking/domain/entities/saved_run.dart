import 'package:equatable/equatable.dart';

class SavedRun extends Equatable {
  const SavedRun({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.duration,
    required this.distanceKm,
    required this.averagePace,
    required this.calories,
    required this.cadence,
    required this.averageHeartRate,
    required this.routePreview,
    required this.achievement,
  });

  final String achievement;
  final int averageHeartRate;
  final Duration averagePace;
  final int cadence;
  final int calories;
  final DateTime completedAt;
  final double distanceKm;
  final Duration duration;
  final String id;
  final String routePreview;
  final DateTime startedAt;

  bool get isValid =>
      id.trim().isNotEmpty &&
      !completedAt.isBefore(startedAt) &&
      !duration.isNegative &&
      distanceKm >= 0 &&
      !averagePace.isNegative &&
      calories >= 0 &&
      cadence >= 0 &&
      averageHeartRate >= 0;

  bool get hasFiveKilometerEffort =>
      distanceKm >= 5 && duration > Duration.zero;

  @override
  List<Object> get props => [
    id,
    startedAt,
    completedAt,
    duration,
    distanceKm,
    averagePace,
    calories,
    cadence,
    averageHeartRate,
    routePreview,
    achievement,
  ];
}
