import 'package:equatable/equatable.dart';

import 'training_session.dart';

class TrainingDay extends Equatable {
  const TrainingDay({
    required this.weekNumber,
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.session,
  });

  final int dayNumber;
  final String description;
  final TrainingSession session;
  final String title;
  final int weekNumber;

  String get sessionKey => 'w$weekNumber-d$dayNumber';

  @override
  List<Object> get props => [
    weekNumber,
    dayNumber,
    title,
    description,
    session,
  ];
}
