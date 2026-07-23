import '../entities/personal_goal.dart';

class GoalPeriod {
  const GoalPeriod({required this.startAt, required this.endAt});

  final DateTime endAt;
  final DateTime startAt;
}

class GoalPeriodException implements Exception {
  const GoalPeriodException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GoalPeriodService {
  const GoalPeriodService();

  GoalPeriod resolve({
    required GoalPeriodType type,
    required DateTime selectedStart,
    DateTime? selectedEnd,
  }) {
    return switch (type) {
      GoalPeriodType.weekly => weekly(selectedStart),
      GoalPeriodType.monthly => monthly(selectedStart),
      GoalPeriodType.custom => custom(
        selectedStart: selectedStart,
        selectedEnd: selectedEnd,
      ),
    };
  }

  GoalPeriod weekly(DateTime date) {
    final start = startOfWeek(date);
    return GoalPeriod(
      startAt: start,
      endAt: start.add(const Duration(days: 7)),
    );
  }

  GoalPeriod monthly(DateTime date) {
    final start = DateTime(date.year, date.month);
    return GoalPeriod(
      startAt: start,
      endAt: DateTime(date.year, date.month + 1),
    );
  }

  GoalPeriod custom({
    required DateTime selectedStart,
    required DateTime? selectedEnd,
  }) {
    if (selectedEnd == null) {
      throw const GoalPeriodException('Choose an end date.');
    }
    final start = startOfDay(selectedStart);
    final end = startOfDay(selectedEnd).add(const Duration(days: 1));
    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      throw const GoalPeriodException('End date cannot be before start date.');
    }
    return GoalPeriod(startAt: start, endAt: end);
  }

  DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime startOfWeek(DateTime date) {
    final day = startOfDay(date);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }
}
