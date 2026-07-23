import 'package:equatable/equatable.dart';

import 'run_route.dart';

class SavedRun extends Equatable {
  SavedRun({
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
    RunRoute? route,
  }) : route = route ?? RunRoute.empty();

  final String achievement;
  final int averageHeartRate;
  final Duration averagePace;
  final int cadence;
  final int calories;
  final DateTime completedAt;
  final double distanceKm;
  final Duration duration;
  final String id;
  final RunRoute route;
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

  bool get hasRoute =>
      route.segments.any((segment) => segment.points.length > 1);

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
    route,
  ];
}
