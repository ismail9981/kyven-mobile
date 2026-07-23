import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../run_tracking/application/run_history_providers.dart';
import '../../run_tracking/domain/entities/saved_run.dart';
import '../domain/entities/goal_evaluation_result.dart';
import '../domain/entities/personal_goal.dart';
import '../domain/repositories/goals_repository.dart';
import '../domain/services/goal_id_generator.dart';
import '../domain/services/goal_period_service.dart';
import '../domain/services/goal_progress_engine.dart';
import '../infrastructure/repositories/hive_goals_repository.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  final repository = HiveGoalsRepository();
  ref.onDispose(() {
    unawaited(repository.dispose());
  });
  return repository;
});

final goalProgressEngineProvider = Provider<GoalProgressEngine>(
  (ref) => const GoalProgressEngine(),
);

final goalPeriodServiceProvider = Provider<GoalPeriodService>(
  (ref) => const GoalPeriodService(),
);

final goalIdGeneratorProvider = Provider<GoalIdGenerator>(
  (ref) => const GoalIdGenerator(),
);

final goalsNowProvider = Provider<DateTime>((ref) => DateTime.now());

final goalsStreamProvider = StreamProvider<List<PersonalGoal>>((ref) {
  return ref.watch(goalsRepositoryProvider).watchGoals();
});

final evaluatedGoalsProvider = Provider<AsyncValue<List<GoalEvaluationResult>>>(
  (ref) {
    final engine = ref.watch(goalProgressEngineProvider);
    final now = ref.watch(goalsNowProvider);
    final goals = ref.watch(goalsStreamProvider);
    final runs = ref.watch(runHistoryProvider);

    return goals.when(
      data: (items) => runs.whenData(
        (savedRuns) =>
            engine.evaluateAll(goals: items, runs: savedRuns, now: now),
      ),
      error: AsyncValue.error,
      loading: AsyncValue.loading,
    );
  },
);

final activeGoalsProvider = Provider<AsyncValue<List<GoalEvaluationResult>>>((
  ref,
) {
  return _filter(ref, GoalStatus.active);
});

final completedGoalsProvider = Provider<AsyncValue<List<GoalEvaluationResult>>>(
  (ref) {
    return _filter(ref, GoalStatus.completed);
  },
);

final expiredGoalsProvider = Provider<AsyncValue<List<GoalEvaluationResult>>>((
  ref,
) {
  return _filter(ref, GoalStatus.expired);
});

final archivedGoalsProvider = Provider<AsyncValue<List<GoalEvaluationResult>>>((
  ref,
) {
  return _filter(ref, GoalStatus.archived);
});

final selectedGoalProvider =
    Provider.family<AsyncValue<GoalEvaluationResult?>, String>((ref, id) {
      return ref.watch(evaluatedGoalsProvider).whenData((goals) {
        for (final goal in goals) {
          if (goal.goal.id == id) return goal;
        }
        return null;
      });
    });

final latestCompletedGoalsProvider =
    NotifierProvider<LatestCompletedGoalsNotifier, List<GoalEvaluationResult>>(
      LatestCompletedGoalsNotifier.new,
    );

final goalsCoordinatorProvider = Provider<GoalsCoordinator>(
  GoalsCoordinator.new,
);

AsyncValue<List<GoalEvaluationResult>> _filter(Ref ref, GoalStatus status) {
  return ref
      .watch(evaluatedGoalsProvider)
      .whenData(
        (goals) => goals
            .where((goal) => goal.progress.status == status)
            .toList(growable: false),
      );
}

class LatestCompletedGoalsNotifier
    extends Notifier<List<GoalEvaluationResult>> {
  @override
  List<GoalEvaluationResult> build() => const [];

  void show(List<GoalEvaluationResult> results) {
    state = results
        .where((result) => result.didBecomeCompleted)
        .toList(growable: false);
  }

  void clear() {
    state = const [];
  }
}

class GoalsCoordinator {
  GoalsCoordinator(this._ref);

  final Ref _ref;

  Future<List<GoalEvaluationResult>> processAfterRunSaved(SavedRun run) async {
    final repository = _ref.read(goalsRepositoryProvider);
    final runRepository = _ref.read(runHistoryRepositoryProvider);
    final engine = _ref.read(goalProgressEngineProvider);
    final now = _ref.read(goalsNowProvider);
    final goals = await repository.loadGoals();
    final runs = await runRepository.getAllRuns();
    final results = engine.evaluateAll(goals: goals, runs: runs, now: now);
    final changed = <GoalEvaluationResult>[];

    for (final result in results) {
      if (result.didBecomeCompleted || result.didBecomeExpired) {
        await repository.updateGoal(result.goal);
        changed.add(result);
      }
    }

    final completions = changed
        .where(
          (result) =>
              result.didBecomeCompleted &&
              result.progress.completedAt != null &&
              result.progress.completedAt == run.completedAt,
        )
        .toList(growable: false);
    _ref.read(latestCompletedGoalsProvider.notifier).show(completions);
    return changed;
  }

  Future<void> createGoal(PersonalGoal goal) async {
    await _ref.read(goalsRepositoryProvider).createGoal(goal);
  }

  Future<void> updateGoal(PersonalGoal goal) async {
    await _ref.read(goalsRepositoryProvider).updateGoal(goal);
  }

  Future<void> archiveGoal(String id) async {
    await _ref
        .read(goalsRepositoryProvider)
        .archiveGoal(id, _ref.read(goalsNowProvider));
  }
}
