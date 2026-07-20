import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/motion_insights.dart';
import '../domain/entities/run_statistics.dart';
import '../domain/entities/saved_run.dart';
import '../domain/repositories/run_history_repository.dart';
import '../domain/services/dashboard_message_generator.dart';
import '../domain/services/motion_insights_service.dart';
import '../domain/services/session_name_generator.dart';
import '../infrastructure/repositories/hive_run_history_repository.dart';

final runHistoryRepositoryProvider = Provider<RunHistoryRepository>((ref) {
  final repository = HiveRunHistoryRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final runHistoryProvider = StreamProvider<List<SavedRun>>((ref) {
  return ref.watch(runHistoryRepositoryProvider).watchRuns();
});

final motionInsightsServiceProvider = Provider<MotionInsightsService>(
  (ref) => const MotionInsightsService(),
);

final sessionNameGeneratorProvider = Provider<SessionNameGenerator>(
  (ref) => const SessionNameGenerator(),
);

final dashboardMessageGeneratorProvider = Provider<DashboardMessageGenerator>(
  (ref) => const DashboardMessageGenerator(),
);

final motionInsightsProvider = Provider<AsyncValue<MotionInsights>>((ref) {
  final service = ref.watch(motionInsightsServiceProvider);
  return ref.watch(runHistoryProvider).whenData(service.calculate);
});

final dashboardMessageProvider = Provider<AsyncValue<DashboardMessage>>((ref) {
  final generator = ref.watch(dashboardMessageGeneratorProvider);
  return ref.watch(motionInsightsProvider).whenData(generator.generate);
});

final latestSavedRunProvider = Provider<AsyncValue<SavedRun?>>((ref) {
  return ref
      .watch(runHistoryProvider)
      .whenData((runs) => runs.isEmpty ? null : runs.first);
});

final runStatisticsProvider = Provider<AsyncValue<RunStatistics>>((ref) {
  return ref.watch(runHistoryProvider).whenData(RunStatistics.fromRuns);
});

final selectedSavedRunProvider = FutureProvider.family<SavedRun?, String>((
  ref,
  runId,
) {
  return ref.watch(runHistoryRepositoryProvider).getRunById(runId);
});
