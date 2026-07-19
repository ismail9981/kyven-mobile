import '../../domain/entities/saved_run.dart';
import 'run_metric_formatters.dart';

extension SavedRunFormatting on SavedRun {
  String get dateLabel => _dateLabel(completedAt);

  String get timeLabel => _timeLabel(completedAt);

  String get accessibilityLabel =>
      'Run on $dateLabel at $timeLabel. '
      '${kilometersLabel(distanceKm)}, ${duration.timeLabel}, '
      '${averagePace.paceLabel} average pace, $calories calories.';
}

String compactDateLabel(DateTime date) {
  return '${_month(date.month)} ${date.day}';
}

String detailedDateLabel(DateTime date) {
  return '${_month(date.month)} ${date.day}, ${date.year}';
}

String kilometersLabel(double value) {
  return '${value.toStringAsFixed(1)} km';
}

String _dateLabel(DateTime date) => detailedDateLabel(date);

String _timeLabel(DateTime date) {
  final hour = date.hour == 0
      ? 12
      : date.hour > 12
      ? date.hour - 12
      : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String _month(int month) {
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
  ][month - 1];
}
