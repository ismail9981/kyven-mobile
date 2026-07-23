import 'package:equatable/equatable.dart';

class TrainingProgress extends Equatable {
  const TrainingProgress({
    required this.planId,
    required this.completedSessions,
    required this.currentWeek,
    required this.currentDay,
    required this.completionPercentage,
  });

  factory TrainingProgress.empty(String planId) {
    return TrainingProgress(
      planId: planId,
      completedSessions: const {},
      currentWeek: 1,
      currentDay: 1,
      completionPercentage: 0,
    );
  }

  final Set<String> completedSessions;
  final double completionPercentage;
  final int currentDay;
  final int currentWeek;
  final String planId;

  bool isCompleted(String sessionKey) => completedSessions.contains(sessionKey);

  TrainingProgress copyWith({
    Set<String>? completedSessions,
    int? currentWeek,
    int? currentDay,
    double? completionPercentage,
  }) {
    return TrainingProgress(
      planId: planId,
      completedSessions: completedSessions ?? this.completedSessions,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  @override
  List<Object> get props => [
    planId,
    completedSessions,
    currentWeek,
    currentDay,
    completionPercentage,
  ];
}
