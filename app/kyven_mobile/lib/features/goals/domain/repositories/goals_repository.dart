import '../entities/personal_goal.dart';

abstract interface class GoalsRepository {
  Stream<List<PersonalGoal>> watchGoals();

  Future<List<PersonalGoal>> loadGoals();

  Future<void> createGoal(PersonalGoal goal);

  Future<void> updateGoal(PersonalGoal goal);

  Future<void> archiveGoal(String id, DateTime archivedAt);
}
