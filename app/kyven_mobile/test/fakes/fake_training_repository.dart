import 'package:kyven_mobile/features/training/domain/entities/training_plan.dart';
import 'package:kyven_mobile/features/training/domain/entities/training_progress.dart';
import 'package:kyven_mobile/features/training/domain/repositories/training_repository.dart';
import 'package:kyven_mobile/features/training/domain/services/built_in_training_plans.dart';

class FakeTrainingRepository implements TrainingRepository {
  FakeTrainingRepository({
    List<TrainingPlan>? plans,
    Map<String, TrainingProgress>? progress,
  }) : _plans = plans ?? BuiltInTrainingPlans.all,
       _progress = {...?progress};

  final List<TrainingPlan> _plans;
  final Map<String, TrainingProgress> _progress;

  @override
  Future<TrainingPlan?> getPlan(String id) async {
    for (final plan in _plans) {
      if (plan.id == id) {
        return plan;
      }
    }
    return null;
  }

  @override
  Future<List<TrainingPlan>> getPlans() async => [..._plans];

  @override
  Future<TrainingProgress> loadProgress(String planId) async {
    return _progress[planId] ?? TrainingProgress.empty(planId);
  }

  @override
  Future<void> saveProgress(TrainingProgress progress) async {
    _progress[progress.planId] = progress;
  }
}
