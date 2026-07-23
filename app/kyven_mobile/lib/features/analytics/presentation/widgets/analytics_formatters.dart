import '../../domain/entities/personal_records.dart';
import '../../domain/entities/training_load_snapshot.dart';

class AnalyticsFormatters {
  const AnalyticsFormatters._();

  static String distance(double value) => '${value.toStringAsFixed(1)} km';

  static String calories(int value) => '$value kcal';

  static String runs(int value) => value == 1 ? '1 run' : '$value runs';

  static String duration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  static String pace(Duration? value) {
    if (value == null || value <= Duration.zero) return '—';
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds /km';
  }

  static String change(double? value, {required bool improvementMode}) {
    if (value == null) return 'No baseline yet';
    final prefix = value > 0 ? '+' : '';
    final suffix = improvementMode && value > 0 ? ' faster' : '';
    return '$prefix${value.toStringAsFixed(0)}%$suffix';
  }

  static String periodLabel(DateTime start, DateTime end) {
    return '${_month(start.month)} ${start.day} – ${_month(end.month)} ${end.day}';
  }

  static String recordTitle(PersonalRecordType type) {
    return switch (type) {
      PersonalRecordType.longestDistance => 'Longest Distance',
      PersonalRecordType.longestDuration => 'Longest Duration',
      PersonalRecordType.fastestAveragePace => 'Best Average Pace',
      PersonalRecordType.fastestOneKm => 'Fastest 1K',
      PersonalRecordType.fastestFiveKm => 'Fastest 5K',
      PersonalRecordType.mostRunsInOneWeek => 'Most Runs / Week',
      PersonalRecordType.highestWeeklyDistance => 'Highest Week',
    };
  }

  static String recordValue(PersonalRecord record) {
    return switch (record.unit) {
      PersonalRecordUnit.kilometers => distance(record.value),
      PersonalRecordUnit.duration => duration(
        Duration(seconds: record.value.round()),
      ),
      PersonalRecordUnit.pace => pace(Duration(seconds: record.value.round())),
      PersonalRecordUnit.runs => runs(record.value.round()),
    };
  }

  static String loadLabel(TrainingLoadClassification classification) {
    return switch (classification) {
      TrainingLoadClassification.low => 'Low',
      TrainingLoadClassification.moderate => 'Moderate',
      TrainingLoadClassification.high => 'High',
      TrainingLoadClassification.veryHigh => 'Very High',
    };
  }

  static String _month(int month) {
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
}
