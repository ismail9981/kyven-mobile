import 'package:equatable/equatable.dart';

enum GoalType { distance, runCount, duration, calories }

enum GoalPeriodType { weekly, monthly, custom }

enum GoalStatus { active, completed, expired, archived }

enum GoalUnit { kilometers, runs, minutes, calories }

class PersonalGoal extends Equatable {
  const PersonalGoal({
    required this.id,
    required this.title,
    required this.type,
    required this.targetValue,
    required this.periodType,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.unit,
    this.completedAt,
    this.archivedAt,
  });

  final DateTime? archivedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime endAt;
  final String id;
  final GoalPeriodType periodType;
  final DateTime startAt;
  final GoalStatus status;
  final double targetValue;
  final String title;
  final GoalType type;
  final GoalUnit unit;
  final DateTime updatedAt;

  bool get isArchived => status == GoalStatus.archived;
  bool get isCompleted => status == GoalStatus.completed;
  bool get isEditable => status == GoalStatus.active;

  PersonalGoal copyWith({
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? createdAt,
    DateTime? endAt,
    String? id,
    GoalPeriodType? periodType,
    DateTime? startAt,
    GoalStatus? status,
    double? targetValue,
    String? title,
    GoalType? type,
    GoalUnit? unit,
    DateTime? updatedAt,
  }) {
    return PersonalGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      periodType: periodType ?? this.periodType,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      unit: unit ?? this.unit,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      archivedAt: clearArchivedAt ? null : archivedAt ?? this.archivedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    targetValue,
    periodType,
    startAt,
    endAt,
    createdAt,
    updatedAt,
    status,
    unit,
    completedAt,
    archivedAt,
  ];
}
