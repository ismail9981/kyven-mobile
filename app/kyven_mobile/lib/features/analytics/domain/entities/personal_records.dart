import 'package:equatable/equatable.dart';

enum PersonalRecordType {
  longestDistance,
  longestDuration,
  fastestAveragePace,
  fastestOneKm,
  fastestFiveKm,
  mostRunsInOneWeek,
  highestWeeklyDistance,
}

enum PersonalRecordUnit { kilometers, duration, pace, runs }

class PersonalRecord extends Equatable {
  const PersonalRecord({
    required this.type,
    required this.value,
    required this.unit,
    required this.achievedAt,
    this.savedRunId,
  });

  final DateTime achievedAt;
  final String? savedRunId;
  final PersonalRecordType type;
  final PersonalRecordUnit unit;
  final double value;

  @override
  List<Object?> get props => [type, value, unit, achievedAt, savedRunId];
}

class PersonalRecords extends Equatable {
  const PersonalRecords({
    required this.longestDistance,
    required this.longestDuration,
    required this.fastestAveragePace,
    required this.fastestOneKm,
    required this.fastestFiveKm,
    required this.mostRunsInOneWeek,
    required this.highestWeeklyDistance,
  });

  factory PersonalRecords.empty() => const PersonalRecords(
    longestDistance: null,
    longestDuration: null,
    fastestAveragePace: null,
    fastestOneKm: null,
    fastestFiveKm: null,
    mostRunsInOneWeek: null,
    highestWeeklyDistance: null,
  );

  final PersonalRecord? fastestAveragePace;
  final PersonalRecord? fastestFiveKm;
  final PersonalRecord? fastestOneKm;
  final PersonalRecord? highestWeeklyDistance;
  final PersonalRecord? longestDistance;
  final PersonalRecord? longestDuration;
  final PersonalRecord? mostRunsInOneWeek;

  List<PersonalRecord> get available => [
    ?longestDistance,
    ?longestDuration,
    ?fastestAveragePace,
    ?mostRunsInOneWeek,
    ?highestWeeklyDistance,
  ];

  @override
  List<Object?> get props => [
    longestDistance,
    longestDuration,
    fastestAveragePace,
    fastestOneKm,
    fastestFiveKm,
    mostRunsInOneWeek,
    highestWeeklyDistance,
  ];
}
