import '../entities/training_plan.dart';
import '../entities/training_progress.dart';

abstract interface class TrainingRepository {
  Future<List<TrainingPlan>> getPlans();

  Future<TrainingPlan?> getPlan(String id);

  Future<void> saveProgress(TrainingProgress progress);

  Future<TrainingProgress> loadProgress(String planId);
}
