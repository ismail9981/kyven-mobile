import '../entities/analytics_period.dart';

class AnalyticsPeriodCalculator {
  const AnalyticsPeriodCalculator();

  AnalyticsPeriod currentWeek(DateTime now) {
    final start = startOfWeek(now);
    return AnalyticsPeriod(
      start: start,
      end: start.add(const Duration(days: 7)),
      type: AnalyticsPeriodType.week,
    );
  }

  AnalyticsPeriod previousWeek(DateTime now) {
    final currentStart = startOfWeek(now);
    final start = currentStart.subtract(const Duration(days: 7));
    return AnalyticsPeriod(
      start: start,
      end: currentStart,
      type: AnalyticsPeriodType.week,
    );
  }

  AnalyticsPeriod currentMonth(DateTime now) {
    final start = DateTime(now.year, now.month);
    return AnalyticsPeriod(
      start: start,
      end: DateTime(now.year, now.month + 1),
      type: AnalyticsPeriodType.month,
    );
  }

  AnalyticsPeriod previousMonth(DateTime now) {
    final end = DateTime(now.year, now.month);
    return AnalyticsPeriod(
      start: DateTime(now.year, now.month - 1),
      end: end,
      type: AnalyticsPeriodType.month,
    );
  }

  AnalyticsPeriod allTime(Iterable<DateTime> dates) {
    final sorted = dates.toList()..sort();
    if (sorted.isEmpty) {
      final epoch = DateTime(1970);
      return AnalyticsPeriod(
        start: epoch,
        end: epoch,
        type: AnalyticsPeriodType.allTime,
      );
    }

    final start = startOfDay(sorted.first);
    return AnalyticsPeriod(
      start: start,
      end: startOfDay(sorted.last).add(const Duration(days: 1)),
      type: AnalyticsPeriodType.allTime,
    );
  }

  DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime startOfWeek(DateTime date) {
    final day = startOfDay(date);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }
}
