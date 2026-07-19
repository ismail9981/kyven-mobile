import 'package:equatable/equatable.dart';

import 'saved_run.dart';

class RunStatistics extends Equatable {
  const RunStatistics({
    required this.totalRuns,
    required this.totalDistanceKm,
    required this.totalDuration,
    required this.averageDistanceKm,
    required this.averagePace,
    required this.longestRunKm,
    required this.latestRunDate,
    required this.fastestFiveKilometerPace,
    required this.currentStreakDays,
  });

  factory RunStatistics.empty() => const RunStatistics(
    totalRuns: 0,
    totalDistanceKm: 0,
    totalDuration: Duration.zero,
    averageDistanceKm: null,
    averagePace: null,
    longestRunKm: null,
    latestRunDate: null,
    fastestFiveKilometerPace: null,
    currentStreakDays: null,
  );

  factory RunStatistics.fromRuns(List<SavedRun> source) {
    final runs = source.where((run) => run.isValid).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    if (runs.isEmpty) {
      return RunStatistics.empty();
    }

    final totalDistance = runs.fold<double>(
      0,
      (total, run) => total + run.distanceKm,
    );
    final totalDuration = runs.fold<Duration>(
      Duration.zero,
      (total, run) => total + run.duration,
    );
    final movingRuns = runs
        .where((run) => run.distanceKm > 0 && run.duration > Duration.zero)
        .toList();
    final averagePace = movingRuns.isEmpty
        ? null
        : Duration(
            milliseconds:
                movingRuns.fold<int>(
                  0,
                  (total, run) => total + run.averagePace.inMilliseconds,
                ) ~/
                movingRuns.length,
          );
    final fiveKilometerRuns = runs
        .where((run) => run.hasFiveKilometerEffort)
        .toList();
    fiveKilometerRuns.sort((a, b) => a.averagePace.compareTo(b.averagePace));

    return RunStatistics(
      totalRuns: runs.length,
      totalDistanceKm: totalDistance,
      totalDuration: totalDuration,
      averageDistanceKm: totalDistance / runs.length,
      averagePace: averagePace,
      longestRunKm: runs.fold<double>(
        0,
        (longest, run) => run.distanceKm > longest ? run.distanceKm : longest,
      ),
      latestRunDate: runs.first.completedAt,
      fastestFiveKilometerPace: fiveKilometerRuns.isEmpty
          ? null
          : fiveKilometerRuns.first.averagePace,
      currentStreakDays: _deriveCurrentStreak(runs),
    );
  }

  final double? averageDistanceKm;
  final Duration? averagePace;
  final int? currentStreakDays;
  final Duration? fastestFiveKilometerPace;
  final DateTime? latestRunDate;
  final double? longestRunKm;
  final double totalDistanceKm;
  final Duration totalDuration;
  final int totalRuns;

  bool get hasRuns => totalRuns > 0;

  static int? _deriveCurrentStreak(List<SavedRun> runs) {
    if (runs.isEmpty) {
      return null;
    }

    final days =
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

    var streak = 1;
    for (var index = 1; index < days.length; index++) {
      final previous = days[index - 1];
      final expected = DateTime(
        previous.year,
        previous.month,
        previous.day - 1,
      );
      if (days[index] != expected) {
        break;
      }
      streak++;
    }

    return streak;
  }

  @override
  List<Object?> get props => [
    totalRuns,
    totalDistanceKm,
    totalDuration,
    averageDistanceKm,
    averagePace,
    longestRunKm,
    latestRunDate,
    fastestFiveKilometerPace,
    currentStreakDays,
  ];
}
