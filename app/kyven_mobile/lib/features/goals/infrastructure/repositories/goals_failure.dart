class GoalsFailure implements Exception {
  const GoalsFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
