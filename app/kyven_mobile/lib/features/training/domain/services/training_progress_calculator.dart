import '../entities/training_day.dart';
import '../entities/training_plan.dart';
import '../entities/training_progress.dart';

class TrainingProgressCalculator {
  const TrainingProgressCalculator();

  TrainingProgress completeSession({
    required TrainingPlan plan,
    required TrainingProgress progress,
    required TrainingDay day,
  }) {
    final completed = {...progress.completedSessions, day.sessionKey};
    final nextDay = _nextIncompleteDay(plan, completed) ?? day;

    return TrainingProgress(
      planId: plan.id,
      completedSessions: completed,
      currentWeek: nextDay.weekNumber,
      currentDay: nextDay.dayNumber,
      completionPercentage: completionPercentage(
        completedSessions: completed.length,
        totalSessions: plan.sessionCount,
      ),
    );
  }

  TrainingProgress normalize({
    required TrainingPlan plan,
    required TrainingProgress progress,
  }) {
    final validSessionKeys = plan.days.map((day) => day.sessionKey).toSet();
    final completed = progress.completedSessions
        .where(validSessionKeys.contains)
        .toSet();
    final nextDay = _nextIncompleteDay(plan, completed) ?? plan.days.last;

    return TrainingProgress(
      planId: plan.id,
      completedSessions: completed,
      currentWeek: nextDay.weekNumber,
      currentDay: nextDay.dayNumber,
      completionPercentage: completionPercentage(
        completedSessions: completed.length,
        totalSessions: plan.sessionCount,
      ),
    );
  }

  double completionPercentage({
    required int completedSessions,
    required int totalSessions,
  }) {
    if (totalSessions <= 0) {
      return 0;
    }
    return (completedSessions / totalSessions).clamp(0, 1);
  }

  TrainingDay? _nextIncompleteDay(
    TrainingPlan plan,
    Set<String> completedSessionKeys,
  ) {
    for (final day in plan.days) {
      if (!completedSessionKeys.contains(day.sessionKey)) {
        return day;
      }
    }
    return null;
  }
}
