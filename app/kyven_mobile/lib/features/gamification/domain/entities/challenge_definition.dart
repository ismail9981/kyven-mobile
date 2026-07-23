import 'package:equatable/equatable.dart';

enum ChallengeCategory {
  distance,
  runCount,
  duration,
  trainingSessions,
  streak,
}

enum ChallengePeriod { weekly, monthly, lifetime }

enum ChallengeUnit { kilometers, runs, minutes, sessions, days }

class ChallengeDefinition extends Equatable {
  const ChallengeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.period,
    required this.targetValue,
    required this.unit,
    required this.xpReward,
    required this.isRepeatable,
  });

  final ChallengeCategory category;
  final String description;
  final String id;
  final bool isRepeatable;
  final ChallengePeriod period;
  final double targetValue;
  final String title;
  final ChallengeUnit unit;
  final int xpReward;

  @override
  List<Object> get props => [
    id,
    title,
    description,
    category,
    period,
    targetValue,
    unit,
    xpReward,
    isRepeatable,
  ];
}
