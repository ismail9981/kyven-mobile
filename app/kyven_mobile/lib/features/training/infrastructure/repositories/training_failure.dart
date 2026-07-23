class TrainingFailure implements Exception {
  const TrainingFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
