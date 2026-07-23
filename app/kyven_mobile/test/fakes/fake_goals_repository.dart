import 'dart:async';

import 'package:kyven_mobile/features/goals/domain/entities/personal_goal.dart';
import 'package:kyven_mobile/features/goals/domain/repositories/goals_repository.dart';

class FakeGoalsRepository implements GoalsRepository {
  FakeGoalsRepository([List<PersonalGoal> goals = const []])
    : _goals = [...goals] {
    _sort();
  }

  final _changes = StreamController<List<PersonalGoal>>.broadcast();
  final List<PersonalGoal> _goals;

  @override
  Future<void> archiveGoal(String id, DateTime archivedAt) async {
    final index = _goals.indexWhere((goal) => goal.id == id);
    if (index == -1) return;
    _goals[index] = _goals[index].copyWith(
      status: GoalStatus.archived,
      archivedAt: archivedAt,
      updatedAt: archivedAt,
    );
    _emit();
  }

  @override
  Future<void> createGoal(PersonalGoal goal) async {
    if (_goals.any((item) => item.id == goal.id)) return;
    _goals.add(goal);
    _sort();
    _emit();
  }

  @override
  Future<List<PersonalGoal>> loadGoals() async => [..._goals];

  @override
  Future<void> updateGoal(PersonalGoal goal) async {
    final index = _goals.indexWhere((item) => item.id == goal.id);
    if (index == -1) {
      _goals.add(goal);
    } else {
      _goals[index] = goal;
    }
    _sort();
    _emit();
  }

  @override
  Stream<List<PersonalGoal>> watchGoals() async* {
    yield [..._goals];
    yield* _changes.stream;
  }

  Future<void> dispose() => _changes.close();

  void _sort() => _goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void _emit() {
    if (!_changes.isClosed) {
      _changes.add([..._goals]);
    }
  }
}
