class GamificationFailure implements Exception {
  const GamificationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
