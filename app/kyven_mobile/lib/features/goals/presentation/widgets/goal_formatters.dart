import '../../domain/entities/personal_goal.dart';

class GoalFormatters {
  const GoalFormatters._();

  static String typeLabel(GoalType type) {
    return switch (type) {
      GoalType.distance => 'Distance',
      GoalType.runCount => 'Run Count',
      GoalType.duration => 'Duration',
      GoalType.calories => 'Calories',
    };
  }

  static String unitLabel(GoalUnit unit) {
    return switch (unit) {
      GoalUnit.kilometers => 'km',
      GoalUnit.runs => 'runs',
      GoalUnit.minutes => 'min',
      GoalUnit.calories => 'cal',
    };
  }

  static String periodLabel(GoalPeriodType type) {
    return switch (type) {
      GoalPeriodType.weekly => 'Weekly',
      GoalPeriodType.monthly => 'Monthly',
      GoalPeriodType.custom => 'Custom',
    };
  }

  static String statusLabel(GoalStatus status) {
    return switch (status) {
      GoalStatus.active => 'Active',
      GoalStatus.completed => 'Completed',
      GoalStatus.expired => 'Expired',
      GoalStatus.archived => 'Archived',
    };
  }

  static String value(double value, GoalUnit unit) {
    return switch (unit) {
      GoalUnit.kilometers => '${value.toStringAsFixed(1)} km',
      GoalUnit.runs => '${value.round()} runs',
      GoalUnit.minutes => '${value.round()} min',
      GoalUnit.calories => '${value.round()} cal',
    };
  }

  static String date(DateTime value) {
    return '${_month(value.month)} ${value.day}, ${value.year}';
  }

  static String range(DateTime start, DateTime end) {
    final inclusiveEnd = end.subtract(const Duration(days: 1));
    return '${date(start)} – ${date(inclusiveEnd)}';
  }

  static String _month(int value) {
    return const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][value - 1];
  }
}
