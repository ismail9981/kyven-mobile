import '../entities/run_statistics.dart';
import '../entities/saved_run.dart';

abstract interface class RunHistoryRepository {
  Future<void> saveRun(SavedRun run);

  Future<List<SavedRun>> getAllRuns();

  Future<SavedRun?> getLatestRun();

  Future<SavedRun?> getRunById(String id);

  Future<void> deleteRun(String id);

  Future<void> clearHistory();

  Stream<List<SavedRun>> watchRuns();

  Future<RunStatistics> getStatistics();
}
