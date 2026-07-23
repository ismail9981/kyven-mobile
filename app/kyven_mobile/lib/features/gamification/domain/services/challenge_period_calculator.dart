import '../entities/challenge_definition.dart';

class ChallengePeriodWindow {
  const ChallengePeriodWindow({required this.start, required this.end});

  final DateTime end;
  final DateTime start;

  String get key => start.toIso8601String().split('T').first;
}

class ChallengePeriodCalculator {
  const ChallengePeriodCalculator();

  ChallengePeriodWindow periodFor(ChallengePeriod period, DateTime now) {
    final date = DateTime(now.year, now.month, now.day);
    return switch (period) {
      ChallengePeriod.weekly => _weekly(date),
      ChallengePeriod.monthly => _monthly(date),
      ChallengePeriod.lifetime => ChallengePeriodWindow(
        start: DateTime(1970),
        end: DateTime(9999, 12, 31, 23, 59, 59, 999),
      ),
    };
  }

  /// KYVEN weeks start on Monday. The period end is exclusive.
  ChallengePeriodWindow _weekly(DateTime date) {
    final start = date.subtract(Duration(days: date.weekday - DateTime.monday));
    return ChallengePeriodWindow(
      start: start,
      end: start.add(const Duration(days: 7)),
    );
  }

  ChallengePeriodWindow _monthly(DateTime date) {
    final start = DateTime(date.year, date.month);
    return ChallengePeriodWindow(
      start: start,
      end: DateTime(date.year, date.month + 1),
    );
  }
}
