import '../entities/motion_insights.dart';

class DashboardMessageGenerator {
  const DashboardMessageGenerator();

  DashboardMessage generate(MotionInsights insights, {DateTime? now}) {
    final current = now ?? DateTime.now();

    if (!insights.hasRuns) {
      return DashboardMessage(
        title: _greeting(current),
        subtitle: "Ready for today's run?",
      );
    }

    final daysSinceLatest = _daysSinceLatestRun(insights, current);
    if (daysSinceLatest != null && daysSinceLatest >= 3) {
      return const DashboardMessage(
        title: "Let's get moving again.",
        subtitle: 'Your next run restarts the rhythm.',
      );
    }

    if (insights.weeklyGoalProgress >= 0.85 &&
        insights.weeklyGoalProgress < 1) {
      return const DashboardMessage(
        title: "You're almost there.",
        subtitle: 'One focused effort can close the week.',
      );
    }

    if (insights.currentStreakDays >= 7) {
      return const DashboardMessage(
        title: 'Keep your streak alive.',
        subtitle: 'Consistency is becoming your signature.',
      );
    }

    if (insights.todayRuns == 1) {
      return const DashboardMessage(
        title: 'Great work.',
        subtitle: 'One run completed today.',
      );
    }

    if (insights.todayRuns > 1) {
      return DashboardMessage(
        title: 'Strong day.',
        subtitle: '${insights.todayRuns} runs completed today.',
      );
    }

    return DashboardMessage(
      title: _greeting(current),
      subtitle: "Ready for today's run?",
    );
  }

  static String _greeting(DateTime now) {
    if (now.hour < 12) {
      return 'Good morning.';
    }
    if (now.hour < 17) {
      return 'Good afternoon.';
    }
    return 'Good evening.';
  }

  static int? _daysSinceLatestRun(MotionInsights insights, DateTime now) {
    final latest = insights.latestRunDate;
    if (latest == null) {
      return null;
    }
    final currentDay = DateTime(now.year, now.month, now.day);
    final latestDay = DateTime(latest.year, latest.month, latest.day);
    return currentDay.difference(latestDay).inDays;
  }
}
