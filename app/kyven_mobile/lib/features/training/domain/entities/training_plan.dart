import 'package:equatable/equatable.dart';

import 'training_day.dart';

enum TrainingDifficulty {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  const TrainingDifficulty(this.label);

  final String label;
}

class TrainingPlan extends Equatable {
  const TrainingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.goal,
    required this.durationWeeks,
    required this.days,
  });

  final List<TrainingDay> days;
  final String description;
  final TrainingDifficulty difficulty;
  final int durationWeeks;
  final String goal;
  final String id;
  final String title;

  int get sessionCount => days.length;

  List<TrainingDay> daysForWeek(int weekNumber) {
    return days
        .where((day) => day.weekNumber == weekNumber)
        .toList(growable: false);
  }

  @override
  List<Object> get props => [
    id,
    title,
    description,
    difficulty,
    goal,
    durationWeeks,
    days,
  ];
}
