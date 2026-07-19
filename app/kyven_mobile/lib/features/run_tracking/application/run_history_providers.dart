import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/run_statistics.dart';
import '../domain/entities/saved_run.dart';
import '../domain/repositories/run_history_repository.dart';
import '../infrastructure/repositories/hive_run_history_repository.dart';

final runHistoryRepositoryProvider = Provider<RunHistoryRepository>((ref) {
  final repository = HiveRunHistoryRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final runHistoryProvider = StreamProvider<List<SavedRun>>((ref) {
  return ref.watch(runHistoryRepositoryProvider).watchRuns();
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
