class RunHistoryFailure implements Exception {
  const RunHistoryFailure(this.message);

  final String message;

  @override
  String toString() => 'RunHistoryFailure($message)';
}
