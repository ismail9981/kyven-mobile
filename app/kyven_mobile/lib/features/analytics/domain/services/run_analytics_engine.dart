import '../../../run_tracking/domain/entities/saved_run.dart';
import '../entities/analytics_comparison.dart';
import '../entities/analytics_period.dart';
import '../entities/analytics_snapshot.dart';
import '../entities/analytics_trend.dart';
import '../entities/personal_records.dart';
import '../entities/run_period_summary.dart';
import '../entities/training_load_snapshot.dart';
import 'analytics_period_calculator.dart';

class RunAnalyticsEngine {
  const RunAnalyticsEngine({
    this.periods = const AnalyticsPeriodCalculator(),
    this.recentPaceRunLimit = 12,
  });

  static const lowTrainingLoadThreshold = 90.0;
  static const moderateTrainingLoadThreshold = 180.0;
  static const highTrainingLoadThreshold = 320.0;

  final AnalyticsPeriodCalculator periods;
  final int recentPaceRunLimit;

  AnalyticsSnapshot analyze({
    required List<SavedRun> runs,
    required DateTime now,
  }) {
    final validRuns = runs.where((run) => run.isValid).toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    final week = periods.currentWeek(now);
    final previousWeek = periods.previousWeek(now);
    final month = periods.currentMonth(now);
    final previousMonth = periods.previousMonth(now);

    final currentWeek = summarize(validRuns, week);
    final previousWeekSummary = summarize(validRuns, previousWeek);
    final currentMonth = summarize(validRuns, month);
    final previousMonthSummary = summarize(validRuns, previousMonth);

    return AnalyticsSnapshot(
      currentWeek: currentWeek,
      previousWeek: previousWeekSummary,
      currentMonth: currentMonth,
      previousMonth: previousMonthSummary,
      weeklyComparison: compare(currentWeek, previousWeekSummary),
      monthlyComparison: compare(currentMonth, previousMonthSummary),
      weeklyDistanceTrend: weeklyDistanceTrend(validRuns, week),
      monthlyDistanceTrend: monthlyWeeklyDistanceTrend(validRuns, month),
      paceTrend: paceTrend(validRuns),
      activityCountTrend: monthlyActivityCountTrend(validRuns, month),
      personalRecords: personalRecords(validRuns),
      trainingLoad: trainingLoad(validRuns, week, previousWeek),
    );
  }

  RunPeriodSummary summarize(List<SavedRun> runs, AnalyticsPeriod period) {
    final periodRuns = _runsIn(runs, period);
    if (periodRuns.isEmpty) {
      return RunPeriodSummary.empty(period);
    }

    final totalDistance = _distance(periodRuns);
    final totalDuration = _duration(periodRuns);
    final paceRuns = periodRuns
        .where((run) => run.distanceKm > 0 && run.duration > Duration.zero)
        .toList();

    return RunPeriodSummary(
      period: period,
      totalDistanceKm: totalDistance,
      totalDuration: totalDuration,
      totalCalories: periodRuns.fold(0, (total, run) => total + run.calories),
      runCount: periodRuns.length,
      averageDistanceKm: totalDistance / periodRuns.length,
      averagePace: _aggregatePace(paceRuns),
      longestRunDistanceKm: periodRuns.fold(
        0,
        (best, run) => run.distanceKm > best ? run.distanceKm : best,
      ),
      longestRunDuration: periodRuns.fold(
        Duration.zero,
        (best, run) => run.duration > best ? run.duration : best,
      ),
    );
  }

  AnalyticsComparison compare(
    RunPeriodSummary current,
    RunPeriodSummary previous,
  ) {
    final distance = _percentageChange(
      current.totalDistanceKm,
      previous.totalDistanceKm,
    );
    final duration = _percentageChange(
      current.totalDuration.inSeconds.toDouble(),
      previous.totalDuration.inSeconds.toDouble(),
    );
    final count = _percentageChange(
      current.runCount.toDouble(),
      previous.runCount.toDouble(),
    );
    final pace = _paceImprovement(current.averagePace, previous.averagePace);

    return AnalyticsComparison(
      current: current,
      previous: previous,
      distanceChangePercent: distance.value,
      durationChangePercent: duration.value,
      runCountChangePercent: count.value,
      paceImprovementPercent: pace.value,
      distanceState: distance.state,
      durationState: duration.state,
      runCountState: count.state,
      paceState: pace.state,
    );
  }

  AnalyticsTrend weeklyDistanceTrend(
    List<SavedRun> runs,
    AnalyticsPeriod week,
  ) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return AnalyticsTrend(
      points: List.generate(7, (index) {
        final start = week.start.add(Duration(days: index));
        final end = start.add(const Duration(days: 1));
        return AnalyticsDataPoint(
          date: start,
          value: _distance(_runsBetween(runs, start, end)),
          label: labels[index],
        );
      }),
    );
  }

  AnalyticsTrend monthlyWeeklyDistanceTrend(
    List<SavedRun> runs,
    AnalyticsPeriod month,
  ) {
    final points = <AnalyticsDataPoint>[];
    var start = month.start;
    var index = 1;
    while (start.isBefore(month.end)) {
      final end = start.add(const Duration(days: 7)).isBefore(month.end)
          ? start.add(const Duration(days: 7))
          : month.end;
      points.add(
        AnalyticsDataPoint(
          date: start,
          value: _distance(_runsBetween(runs, start, end)),
          label: 'W$index',
        ),
      );
      start = end;
      index += 1;
    }
    return AnalyticsTrend(points: points);
  }

  AnalyticsTrend monthlyActivityCountTrend(
    List<SavedRun> runs,
    AnalyticsPeriod month,
  ) {
    final distanceBuckets = monthlyWeeklyDistanceTrend(const [], month).points;
    return AnalyticsTrend(
      points: distanceBuckets
          .map((bucket) {
            final index = distanceBuckets.indexOf(bucket);
            final end = index == distanceBuckets.length - 1
                ? month.end
                : distanceBuckets[index + 1].date;
            return AnalyticsDataPoint(
              date: bucket.date,
              value: _runsBetween(runs, bucket.date, end).length.toDouble(),
              label: bucket.label,
            );
          })
          .toList(growable: false),
    );
  }

  AnalyticsTrend paceTrend(List<SavedRun> runs) {
    final valid =
        runs
            .where((run) => run.distanceKm > 0 && run.duration > Duration.zero)
            .toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final latest = valid.take(recentPaceRunLimit).toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    return AnalyticsTrend(
      points: latest
          .map(
            (run) => AnalyticsDataPoint(
              date: run.completedAt,
              value: run.duration.inSeconds / run.distanceKm,
              label: '${run.completedAt.month}/${run.completedAt.day}',
            ),
          )
          .toList(growable: false),
    );
  }

  PersonalRecords personalRecords(List<SavedRun> runs) {
    if (runs.isEmpty) return PersonalRecords.empty();

    final ordered = [...runs]
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    final paceRuns = ordered
        .where((run) => run.distanceKm > 0 && run.duration > Duration.zero)
        .toList();

    return PersonalRecords(
      longestDistance: _bestRunRecord(
        ordered,
        type: PersonalRecordType.longestDistance,
        unit: PersonalRecordUnit.kilometers,
        valueFor: (run) => run.distanceKm,
        isBetter: (candidate, best) => candidate > best,
      ),
      longestDuration: _bestRunRecord(
        ordered,
        type: PersonalRecordType.longestDuration,
        unit: PersonalRecordUnit.duration,
        valueFor: (run) => run.duration.inSeconds.toDouble(),
        isBetter: (candidate, best) => candidate > best,
      ),
      fastestAveragePace: _bestRunRecord(
        paceRuns,
        type: PersonalRecordType.fastestAveragePace,
        unit: PersonalRecordUnit.pace,
        valueFor: (run) => run.duration.inSeconds / run.distanceKm,
        isBetter: (candidate, best) => candidate < best,
      ),
      fastestOneKm: null,
      fastestFiveKm: null,
      mostRunsInOneWeek: _bestWeeklyRecord(
        ordered,
        type: PersonalRecordType.mostRunsInOneWeek,
        unit: PersonalRecordUnit.runs,
        valueFor: (weekRuns) => weekRuns.length.toDouble(),
      ),
      highestWeeklyDistance: _bestWeeklyRecord(
        ordered,
        type: PersonalRecordType.highestWeeklyDistance,
        unit: PersonalRecordUnit.kilometers,
        valueFor: _distance,
      ),
    );
  }

  TrainingLoadSnapshot trainingLoad(
    List<SavedRun> runs,
    AnalyticsPeriod currentWeek,
    AnalyticsPeriod previousWeek,
  ) {
    final currentPoints = List.generate(7, (index) {
      final start = currentWeek.start.add(Duration(days: index));
      final end = start.add(const Duration(days: 1));
      final load = _runsBetween(
        runs,
        start,
        end,
      ).fold<double>(0, (sum, run) => sum + _loadFor(run));
      return AnalyticsDataPoint(
        date: start,
        value: load,
        label: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
      );
    });
    final currentLoad = currentPoints.fold<double>(
      0,
      (sum, point) => sum + point.value,
    );
    final previousLoad = _runsIn(
      runs,
      previousWeek,
    ).fold<double>(0, (sum, run) => sum + _loadFor(run));
    final change = _percentageChange(currentLoad, previousLoad);

    return TrainingLoadSnapshot(
      currentWeeklyLoad: currentLoad,
      previousWeeklyLoad: previousLoad,
      percentageChange: change.value,
      classification: _classifyLoad(currentLoad),
      dailyLoadPoints: currentPoints,
    );
  }

  static List<SavedRun> _runsIn(List<SavedRun> runs, AnalyticsPeriod period) {
    return runs.where((run) => period.contains(run.completedAt)).toList();
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
    return runs.fold(0, (sum, run) => sum + run.distanceKm);
  }

  static Duration _duration(List<SavedRun> runs) {
    return runs.fold(Duration.zero, (sum, run) => sum + run.duration);
  }

  static Duration? _aggregatePace(List<SavedRun> runs) {
    final totalDistance = _distance(runs);
    final totalDuration = _duration(runs);
    if (totalDistance <= 0 || totalDuration <= Duration.zero) {
      return null;
    }
    return Duration(seconds: (totalDuration.inSeconds / totalDistance).round());
  }

  static _Change _percentageChange(double current, double previous) {
    if (current == 0 && previous == 0) {
      return const _Change(null, AnalyticsChangeState.bothZero);
    }
    if (previous == 0) {
      return const _Change(null, AnalyticsChangeState.noBaseline);
    }
    if (current == 0) {
      return const _Change(-100, AnalyticsChangeState.missingCurrent);
    }
    return _Change(
      ((current - previous) / previous) * 100,
      AnalyticsChangeState.available,
    );
  }

  static _Change _paceImprovement(Duration? current, Duration? previous) {
    if (current == null && previous == null) {
      return const _Change(null, AnalyticsChangeState.bothZero);
    }
    if (previous == null || previous <= Duration.zero) {
      return const _Change(null, AnalyticsChangeState.noBaseline);
    }
    if (current == null || current <= Duration.zero) {
      return const _Change(null, AnalyticsChangeState.missingCurrent);
    }
    return _Change(
      ((previous.inSeconds - current.inSeconds) / previous.inSeconds) * 100,
      AnalyticsChangeState.available,
    );
  }

  static PersonalRecord? _bestRunRecord(
    List<SavedRun> runs, {
    required PersonalRecordType type,
    required PersonalRecordUnit unit,
    required double Function(SavedRun run) valueFor,
    required bool Function(double candidate, double best) isBetter,
  }) {
    SavedRun? bestRun;
    double? bestValue;
    for (final run in runs) {
      final value = valueFor(run);
      if (value <= 0) continue;
      if (bestValue == null || isBetter(value, bestValue)) {
        bestValue = value;
        bestRun = run;
      }
    }
    if (bestRun == null || bestValue == null) return null;
    return PersonalRecord(
      type: type,
      value: bestValue,
      unit: unit,
      achievedAt: bestRun.completedAt,
      savedRunId: bestRun.id,
    );
  }

  PersonalRecord? _bestWeeklyRecord(
    List<SavedRun> runs, {
    required PersonalRecordType type,
    required PersonalRecordUnit unit,
    required double Function(List<SavedRun> weekRuns) valueFor,
  }) {
    final grouped = <DateTime, List<SavedRun>>{};
    for (final run in runs) {
      grouped
          .putIfAbsent(periods.startOfWeek(run.completedAt), () => [])
          .add(run);
    }

    DateTime? bestWeek;
    double? bestValue;
    for (final entry
        in grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
      final value = valueFor(entry.value);
      if (value <= 0) continue;
      if (bestValue == null || value > bestValue) {
        bestValue = value;
        bestWeek = entry.key;
      }
    }

    if (bestWeek == null || bestValue == null) return null;
    return PersonalRecord(
      type: type,
      value: bestValue,
      unit: unit,
      achievedAt: bestWeek,
    );
  }

  static double _loadFor(SavedRun run) {
    if (run.duration <= Duration.zero || run.distanceKm <= 0) return 0;
    final secondsPerKm = run.duration.inSeconds / run.distanceKm;
    final factor = switch (secondsPerKm) {
      <= 300 => 1.4,
      <= 360 => 1.2,
      <= 450 => 1.0,
      _ => 0.8,
    };
    return (run.duration.inMinutes +
            run.duration.inSeconds.remainder(60) / 60) *
        factor;
  }

  static TrainingLoadClassification _classifyLoad(double load) {
    return switch (load) {
      < lowTrainingLoadThreshold => TrainingLoadClassification.low,
      < moderateTrainingLoadThreshold => TrainingLoadClassification.moderate,
      < highTrainingLoadThreshold => TrainingLoadClassification.high,
      _ => TrainingLoadClassification.veryHigh,
    };
  }
}

class _Change {
  const _Change(this.value, this.state);

  final AnalyticsChangeState state;
  final double? value;
}
