import 'package:equatable/equatable.dart';

enum PerformanceRating {
  exceptional('Exceptional'),
  excellent('Excellent'),
  strong('Strong'),
  steady('Steady'),
  recoveryFocus('Recovery focus');

  const PerformanceRating(this.label);

  final String label;
}

enum PaceConsistency {
  excellent('Excellent consistency'),
  good('Good consistency'),
  moderate('Moderate consistency'),
  poor('Poor consistency'),
  unavailable('Not enough pace data');

  const PaceConsistency(this.label);

  final String label;
}

enum FatigueLevel {
  low('Low fatigue'),
  moderate('Moderate fatigue'),
  high('High fatigue'),
  unavailable('Not enough fatigue data');

  const FatigueLevel(this.label);

  final String label;
}

enum NegativeSplitResult {
  achieved('Negative split achieved'),
  even('Even pacing'),
  missed('Positive split'),
  unavailable('Not enough split data');

  const NegativeSplitResult(this.label);

  final String label;
}

enum RecoveryRecommendation {
  buildGradually('Build gradually'),
  normalTraining('Resume normal training'),
  easyRecovery('Easy recovery next'),
  restAndReset('Rest and reset');

  const RecoveryRecommendation(this.label);

  final String label;
}

class RunAnalysis extends Equatable {
  const RunAnalysis({
    required this.performanceScore,
    required this.performanceRating,
    required this.paceConsistency,
    required this.fatigueLevel,
    required this.negativeSplitResult,
    required this.recoveryRecommendation,
    required this.coachTips,
    required this.summaryText,
  });

  final List<String> coachTips;
  final FatigueLevel fatigueLevel;
  final NegativeSplitResult negativeSplitResult;
  final PaceConsistency paceConsistency;
  final PerformanceRating performanceRating;
  final int performanceScore;
  final RecoveryRecommendation recoveryRecommendation;
  final String summaryText;

  @override
  List<Object> get props => [
    performanceScore,
    performanceRating,
    paceConsistency,
    fatigueLevel,
    negativeSplitResult,
    recoveryRecommendation,
    coachTips,
    summaryText,
  ];
}
