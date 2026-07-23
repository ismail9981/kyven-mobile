import 'package:equatable/equatable.dart';

class ChallengeProgress extends Equatable {
  const ChallengeProgress({
    required this.challengeId,
    required this.currentValue,
    required this.targetValue,
    required this.periodStart,
    required this.periodEnd,
    required this.isCompleted,
    required this.rewardClaimed,
  });

  final String challengeId;
  final double currentValue;
  final bool isCompleted;
  final DateTime periodEnd;
  final DateTime periodStart;
  final bool rewardClaimed;
  final double targetValue;

  double get progressFraction {
    if (targetValue <= 0) {
      return 0;
    }
    return (currentValue / targetValue).clamp(0, 1);
  }

  @override
  List<Object> get props => [
    challengeId,
    currentValue,
    targetValue,
    periodStart,
    periodEnd,
    isCompleted,
    rewardClaimed,
  ];
}
