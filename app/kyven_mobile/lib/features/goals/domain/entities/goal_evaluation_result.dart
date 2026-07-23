import 'package:equatable/equatable.dart';

import 'goal_progress.dart';
import 'personal_goal.dart';

class GoalEvaluationResult extends Equatable {
  const GoalEvaluationResult({
    required this.goal,
    required this.progress,
    required this.didBecomeCompleted,
    required this.didBecomeExpired,
  });

  final bool didBecomeCompleted;
  final bool didBecomeExpired;
  final PersonalGoal goal;
  final GoalProgress progress;

  @override
  List<Object> get props => [
    goal,
    progress,
    didBecomeCompleted,
    didBecomeExpired,
  ];
}
