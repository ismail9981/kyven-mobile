import 'dart:async';

import 'package:kyven_mobile/features/run_tracking/domain/entities/run_statistics.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/saved_run.dart';
import 'package:kyven_mobile/features/run_tracking/domain/repositories/run_history_repository.dart';

class FakeRunHistoryRepository implements RunHistoryRepository {
  FakeRunHistoryRepository([List<SavedRun> runs = const []])
    : _runs = [...runs] {
    _sort();
  }

  final _changes = StreamController<List<SavedRun>>.broadcast();
  final List<SavedRun> _runs;

  @override
  Future<void> saveRun(SavedRun run) async {
    if (_runs.any((saved) => saved.id == run.id)) {
      return;
    }
    _runs.add(run);
    _sort();
    _emit();
  }

  @override
  Future<List<SavedRun>> getAllRuns() async => [..._runs];

  @override
  Future<SavedRun?> getLatestRun() async => _runs.isEmpty ? null : _runs.first;

  @override
  Future<SavedRun?> getRunById(String id) async {
    for (final run in _runs) {
      if (run.id == id) {
        return run;
      }
    }
    return null;
  }

  @override
  Future<void> deleteRun(String id) async {
    _runs.removeWhere((run) => run.id == id);
    _emit();
  }

  @override
  Future<void> clearHistory() async {
    _runs.clear();
    _emit();
  }

  @override
  Stream<List<SavedRun>> watchRuns() async* {
    yield [..._runs];
    yield* _changes.stream;
  }

  @override
  Future<RunStatistics> getStatistics() async {
    return RunStatistics.fromRuns(_runs);
  }

  Future<void> dispose() => _changes.close();

  void _sort() => _runs.sort((a, b) => b.completedAt.compareTo(a.completedAt));

  void _emit() {
    if (!_changes.isClosed) {
      _changes.add([..._runs]);
    }
  }
}
