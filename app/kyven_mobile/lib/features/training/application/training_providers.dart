import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../gamification/application/gamification_providers.dart';
import '../domain/entities/training_day.dart';
import '../domain/entities/training_plan.dart';
import '../domain/entities/training_progress.dart';
import '../domain/repositories/training_repository.dart';
import '../domain/services/training_progress_calculator.dart';
import '../infrastructure/repositories/hive_training_repository.dart';

final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  return HiveTrainingRepository();
});

final trainingProgressCalculatorProvider = Provider<TrainingProgressCalculator>(
  (ref) => const TrainingProgressCalculator(),
);

final trainingPlansProvider = FutureProvider<List<TrainingPlan>>((ref) {
  return ref.watch(trainingRepositoryProvider).getPlans();
});

final trainingPlanProvider = FutureProvider.family<TrainingPlan?, String>((
  ref,
  planId,
) {
  return ref.watch(trainingRepositoryProvider).getPlan(planId);
});

final trainingProgressProvider =
    FutureProvider.family<TrainingProgress, String>((ref, planId) async {
      final repository = ref.watch(trainingRepositoryProvider);
      final calculator = ref.watch(trainingProgressCalculatorProvider);
      final plan = await repository.getPlan(planId);
      final progress = await repository.loadProgress(planId);
      if (plan == null || plan.days.isEmpty) {
        return progress;
      }
      return calculator.normalize(plan: plan, progress: progress);
    });

final trainingProgressActionsProvider = Provider<TrainingProgressActions>((
  ref,
) {
  return TrainingProgressActions(ref);
});

class TrainingProgressActions {
  TrainingProgressActions(this._ref);

  final Ref _ref;

  Future<void> completeSession({
    required TrainingPlan plan,
    required TrainingProgress progress,
    required TrainingDay day,
  }) async {
    final calculator = _ref.read(trainingProgressCalculatorProvider);
    final repository = _ref.read(trainingRepositoryProvider);
    final nextProgress = calculator.completeSession(
      plan: plan,
      progress: progress,
      day: day,
    );
    await repository.saveProgress(nextProgress);
    await _ref
        .read(gamificationCoordinatorProvider)
        .processTrainingSessionCompleted('${plan.id}:${day.sessionKey}');
    _ref.invalidate(trainingProgressProvider(plan.id));
  }
}
