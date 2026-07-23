import 'package:equatable/equatable.dart';

enum TrainingSessionType {
  easyRun('Easy Run'),
  tempo('Tempo'),
  interval('Intervals'),
  longRun('Long Run'),
  recovery('Recovery'),
  rest('Rest');

  const TrainingSessionType(this.label);

  final String label;
}

class TrainingSession extends Equatable {
  const TrainingSession({
    required this.type,
    required this.distanceKm,
    required this.estimatedDuration,
    required this.notes,
    this.targetPace,
  });

  final double distanceKm;
  final Duration estimatedDuration;
  final String notes;
  final Duration? targetPace;
  final TrainingSessionType type;

  @override
  List<Object?> get props => [
    type,
    distanceKm,
    targetPace,
    estimatedDuration,
    notes,
  ];
}
