import 'package:equatable/equatable.dart';

import 'personal_goal.dart';

class GoalProgress extends Equatable {
  const GoalProgress({
    required this.goalId,
    required this.currentValue,
    required this.targetValue,
    required this.progressFraction,
    required this.remainingValue,
    required this.status,
    required this.completedAt,
    required this.daysRemaining,
    required this.isOnTrack,
  });

  final DateTime? completedAt;
  final double currentValue;
  final int daysRemaining;
  final String goalId;
  final bool isOnTrack;
  final double progressFraction;
  final double remainingValue;
  final GoalStatus status;
  final double targetValue;

  @override
  List<Object?> get props => [
    goalId,
    currentValue,
    targetValue,
    progressFraction,
    remainingValue,
    status,
    completedAt,
    daysRemaining,
    isOnTrack,
  ];
}
