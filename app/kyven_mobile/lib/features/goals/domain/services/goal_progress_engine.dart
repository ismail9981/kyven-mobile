import '../../../run_tracking/domain/entities/saved_run.dart';
import '../entities/goal_evaluation_result.dart';
import '../entities/goal_progress.dart';
import '../entities/personal_goal.dart';

class GoalProgressEngine {
  const GoalProgressEngine();

  GoalEvaluationResult evaluate({
    required PersonalGoal goal,
    required List<SavedRun> runs,
    required DateTime now,
  }) {
    final qualifyingRuns = runs
        .where((run) => run.isValid && _contains(goal, run.completedAt))
        .toList(growable: false);
    final currentValue = _currentValue(goal.type, qualifyingRuns);
    final target = goal.targetValue.isFinite && goal.targetValue > 0
        ? goal.targetValue
        : 0.0;
    final fraction = target <= 0
        ? 0.0
        : (currentValue / target).clamp(0, 1).toDouble();
    final remaining = target <= 0
        ? 0.0
        : (target - currentValue).clamp(0, double.infinity).toDouble();
    final previousStatus = goal.status;
    final reachedTarget = target > 0 && currentValue >= target;

    GoalStatus status;
    DateTime? completedAt = goal.completedAt;
    if (previousStatus == GoalStatus.archived) {
      status = GoalStatus.archived;
    } else if (previousStatus == GoalStatus.completed) {
      status = GoalStatus.completed;
      completedAt ??= _completionTime(goal, qualifyingRuns) ?? now;
    } else if (reachedTarget) {
      status = GoalStatus.completed;
      completedAt = _completionTime(goal, qualifyingRuns) ?? now;
    } else if (!now.isBefore(goal.endAt)) {
      status = GoalStatus.expired;
    } else {
      status = GoalStatus.active;
    }

    final updatedGoal = goal.copyWith(status: status, completedAt: completedAt);
    final progress = GoalProgress(
      goalId: goal.id,
      currentValue: currentValue,
      targetValue: target,
      progressFraction: fraction,
      remainingValue: remaining,
      status: status,
      completedAt: completedAt,
      daysRemaining: _daysRemaining(goal, now),
      isOnTrack: _isOnTrack(
        status: status,
        startAt: goal.startAt,
        endAt: goal.endAt,
        now: now,
        actualProgress: fraction,
      ),
    );

    return GoalEvaluationResult(
      goal: updatedGoal,
      progress: progress,
      didBecomeCompleted:
          previousStatus != GoalStatus.completed &&
          status == GoalStatus.completed,
      didBecomeExpired:
          previousStatus != GoalStatus.expired && status == GoalStatus.expired,
    );
  }

  List<GoalEvaluationResult> evaluateAll({
    required List<PersonalGoal> goals,
    required List<SavedRun> runs,
    required DateTime now,
  }) {
    return goals
        .map((goal) => evaluate(goal: goal, runs: runs, now: now))
        .toList(growable: false);
  }

  static bool _contains(PersonalGoal goal, DateTime completedAt) {
    return !completedAt.isBefore(goal.startAt) &&
        completedAt.isBefore(goal.endAt);
  }

  static double _currentValue(GoalType type, List<SavedRun> runs) {
    return switch (type) {
      GoalType.distance => runs.fold(0, (sum, run) => sum + run.distanceKm),
      GoalType.runCount => runs.length.toDouble(),
      GoalType.duration => runs.fold(
        0,
        (sum, run) => sum + run.duration.inMinutes,
      ),
      GoalType.calories => runs.fold(0, (sum, run) => sum + run.calories),
    };
  }

  static DateTime? _completionTime(PersonalGoal goal, List<SavedRun> runs) {
    var total = 0.0;
    final ordered = [...runs]
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    for (final run in ordered) {
      total += _currentValue(goal.type, [run]);
      if (total >= goal.targetValue) {
        return run.completedAt;
      }
    }
    return null;
  }

  static int _daysRemaining(PersonalGoal goal, DateTime now) {
    if (!now.isBefore(goal.endAt)) {
      return 0;
    }
    final remaining = goal.endAt.difference(now);
    return (remaining.inHours / 24).ceil().clamp(0, 99999).toInt();
  }

  static bool _isOnTrack({
    required GoalStatus status,
    required DateTime startAt,
    required DateTime endAt,
    required DateTime now,
    required double actualProgress,
  }) {
    if (status == GoalStatus.completed) return true;
    if (status == GoalStatus.expired) return false;
    if (status == GoalStatus.archived) return actualProgress >= 1;
    if (now.isBefore(startAt)) return true;

    final total = endAt.difference(startAt).inSeconds;
    if (total <= 0) return actualProgress >= 1;
    final elapsed = now.difference(startAt).inSeconds;
    final expected = (elapsed / total).clamp(0, 1).toDouble();
    return actualProgress >= expected;
  }
}
