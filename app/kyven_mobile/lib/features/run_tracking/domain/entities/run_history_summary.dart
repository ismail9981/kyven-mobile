import 'package:equatable/equatable.dart';

class RunHistorySummary extends Equatable {
  const RunHistorySummary({
    required this.totalRuns,
    required this.totalDistanceKm,
    required this.totalDuration,
  });

  factory RunHistorySummary.empty() => const RunHistorySummary(
    totalRuns: 0,
    totalDistanceKm: 0,
    totalDuration: Duration.zero,
  );

  final double totalDistanceKm;
  final Duration totalDuration;
  final int totalRuns;

  @override
  List<Object> get props => [totalRuns, totalDistanceKm, totalDuration];
}
