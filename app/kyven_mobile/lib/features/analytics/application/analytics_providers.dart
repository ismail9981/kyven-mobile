import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../run_tracking/application/run_history_providers.dart';
import '../domain/entities/analytics_period.dart';
import '../domain/entities/analytics_snapshot.dart';
import '../domain/services/run_analytics_engine.dart';

final analyticsNowProvider = Provider<DateTime>((ref) => DateTime.now());

final runAnalyticsEngineProvider = Provider<RunAnalyticsEngine>(
  (ref) => const RunAnalyticsEngine(),
);

final selectedAnalyticsPeriodProvider =
    NotifierProvider<SelectedAnalyticsPeriodNotifier, AnalyticsPeriodType>(
      SelectedAnalyticsPeriodNotifier.new,
    );

final analyticsSnapshotProvider = Provider<AsyncValue<AnalyticsSnapshot>>((
  ref,
) {
  final engine = ref.watch(runAnalyticsEngineProvider);
  final now = ref.watch(analyticsNowProvider);
  return ref
      .watch(runHistoryProvider)
      .whenData((runs) => engine.analyze(runs: runs, now: now));
});

class SelectedAnalyticsPeriodNotifier extends Notifier<AnalyticsPeriodType> {
  @override
  AnalyticsPeriodType build() => AnalyticsPeriodType.week;

  void select(AnalyticsPeriodType period) => state = period;
}
