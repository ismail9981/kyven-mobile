import '../entities/motion_insights.dart';
import '../entities/saved_run.dart';

class MotionInsightsService {
  const MotionInsightsService({this.weeklyGoalKm = 20});

  final double weeklyGoalKm;

  MotionInsights calculate(List<SavedRun> source, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final runs = source.where((run) => run.isValid).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    if (runs.isEmpty) {
      return MotionInsights.empty(weeklyGoalKm: weeklyGoalKm);
    }

    final todayStart = _startOfDay(current);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final weekStart = _startOfWeek(current);
    final nextWeekStart = weekStart.add(const Duration(days: 7));
    final monthStart = DateTime(current.year, current.month);
    final nextMonthStart = DateTime(current.year, current.month + 1);

    final todayRuns = _runsBetween(runs, todayStart, tomorrowStart);
    final weekRuns = _runsBetween(runs, weekStart, nextWeekStart);
    final monthRuns = _runsBetween(runs, monthStart, nextMonthStart);
    final movingRuns = runs
        .where((run) => run.distanceKm > 0 && run.averagePace > Duration.zero)
        .toList();

    return MotionInsights(
      totalRuns: runs.length,
      weeklyRuns: weekRuns.length,
      todayRuns: todayRuns.length,
      todayDistanceKm: _distance(todayRuns),
      todayDuration: _duration(todayRuns),
      todayCalories: todayRuns.fold(0, (total, run) => total + run.calories),
      weeklyDistanceKm: _distance(weekRuns),
      monthlyDistanceKm: _distance(monthRuns),
      totalDistanceKm: _distance(runs),
      totalDuration: _duration(runs),
      currentStreakDays: _currentStreak(runs, now: current),
      longestRunKm: runs.fold<double>(
        0,
        (longest, run) => run.distanceKm > longest ? run.distanceKm : longest,
      ),
      averagePace: _averagePace(movingRuns),
      fastestAveragePace: movingRuns.isEmpty
          ? null
          : movingRuns
                .map((run) => run.averagePace)
                .reduce((best, pace) => pace < best ? pace : best),
      averageDuration: Duration(
        milliseconds: _duration(runs).inMilliseconds ~/ runs.length,
      ),
      latestRunDate: runs.first.completedAt,
      latestRuns: runs.take(3).toList(growable: false),
      weeklyProgress: _weeklyProgress(weekRuns, weekStart),
      weeklyGoalKm: weeklyGoalKm,
    );
  }

  static DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime _startOfWeek(DateTime date) {
    final day = _startOfDay(date);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static List<SavedRun> _runsBetween(
    List<SavedRun> runs,
    DateTime start,
    DateTime end,
  ) {
    return runs
        .where(
          (run) =>
              !run.completedAt.isBefore(start) && run.completedAt.isBefore(end),
        )
        .toList();
  }

  static double _distance(List<SavedRun> runs) {
    return runs.fold(0, (total, run) => total + run.distanceKm);
  }

  static Duration _duration(List<SavedRun> runs) {
    return runs.fold(Duration.zero, (total, run) => total + run.duration);
  }

  static Duration? _averagePace(List<SavedRun> runs) {
    if (runs.isEmpty) {
      return null;
    }
    return Duration(
      milliseconds:
          runs.fold<int>(
            0,
            (total, run) => total + run.averagePace.inMilliseconds,
          ) ~/
          runs.length,
    );
  }

  static int _currentStreak(List<SavedRun> runs, {required DateTime now}) {
    final runDays =
        runs
            .map(
              (run) => DateTime(
                run.completedAt.year,
                run.completedAt.month,
                run.completedAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (runDays.isEmpty) {
      return 0;
    }

    var expected = _startOfDay(now);
    if (runDays.first != expected) {
      expected = expected.subtract(const Duration(days: 1));
      if (runDays.first != expected) {
        return 0;
      }
    }

    var streak = 0;
    for (final day in runDays) {
      if (day != expected) {
        break;
      }
      streak++;
      expected = expected.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static List<MotionWeekDay> _weeklyProgress(
    List<SavedRun> weekRuns,
    DateTime weekStart,
  ) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxDistance = weekRuns.fold<double>(
      1,
      (max, run) => run.distanceKm > max ? run.distanceKm : max,
    );

    return List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      final nextDay = day.add(const Duration(days: 1));
      final distance = _distance(_runsBetween(weekRuns, day, nextDay));
      return MotionWeekDay(
        label: labels[index],
        distanceKm: distance,
        goalKm: maxDistance,
      );
    });
  }
}
