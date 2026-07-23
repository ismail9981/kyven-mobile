class GoalIdGenerator {
  const GoalIdGenerator();

  String generate(DateTime now) {
    return 'goal-${now.microsecondsSinceEpoch}';
  }
}
