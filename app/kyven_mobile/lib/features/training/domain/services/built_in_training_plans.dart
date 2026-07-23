import '../entities/training_day.dart';
import '../entities/training_plan.dart';
import '../entities/training_session.dart';

abstract final class BuiltInTrainingPlans {
  static List<TrainingPlan> get all => [
    _beginner5k,
    _improvePace,
    _tenKPreparation,
  ];

  static TrainingPlan? byId(String id) {
    for (final plan in all) {
      if (plan.id == id) {
        return plan;
      }
    }
    return null;
  }

  static final TrainingPlan _beginner5k = TrainingPlan(
    id: 'beginner-5k',
    title: 'Beginner 5K',
    description: 'Build a calm aerobic base and arrive at your first 5K ready.',
    difficulty: TrainingDifficulty.beginner,
    goal: 'Complete your first 5K',
    durationWeeks: 8,
    days: _buildPlanDays(
      weeks: 8,
      sessionsForWeek: (week) => [
        _session(
          type: TrainingSessionType.easyRun,
          distanceKm: 1.6 + (week * 0.25),
          minutes: 18 + week,
          notes: 'Keep the effort conversational and relaxed.',
        ),
        _session(
          type: TrainingSessionType.recovery,
          distanceKm: 1.2 + (week * 0.2),
          minutes: 16 + week,
          notes: 'Move gently and finish feeling fresh.',
        ),
        _session(
          type: TrainingSessionType.longRun,
          distanceKm: 2.2 + (week * 0.35),
          minutes: 24 + (week * 2),
          notes: 'Stay patient. Distance matters more than pace.',
        ),
      ],
    ),
  );

  static final TrainingPlan _improvePace = TrainingPlan(
    id: 'improve-pace',
    title: 'Improve Pace',
    description:
        'Sharpen rhythm with measured tempo work and controlled intervals.',
    difficulty: TrainingDifficulty.intermediate,
    goal: 'Run faster with control',
    durationWeeks: 6,
    days: _buildPlanDays(
      weeks: 6,
      sessionsForWeek: (week) => [
        _session(
          type: TrainingSessionType.easyRun,
          distanceKm: 4.0 + (week * 0.35),
          minutes: 28 + week,
          notes: 'Keep this smooth so the quality days stay sharp.',
        ),
        _session(
          type: TrainingSessionType.tempo,
          distanceKm: 4.5 + (week * 0.3),
          minutes: 30 + week,
          targetPace: const Duration(minutes: 5, seconds: 10),
          notes: 'Hold a strong but sustainable rhythm.',
        ),
        _session(
          type: TrainingSessionType.interval,
          distanceKm: 4.0 + (week * 0.25),
          minutes: 32 + week,
          targetPace: const Duration(minutes: 4, seconds: 45),
          notes: 'Fast repeats. Full control between efforts.',
        ),
        _session(
          type: TrainingSessionType.longRun,
          distanceKm: 6.0 + (week * 0.5),
          minutes: 45 + (week * 2),
          notes: 'Finish steady, not empty.',
        ),
      ],
    ),
  );

  static final TrainingPlan _tenKPreparation = TrainingPlan(
    id: '10k-preparation',
    title: '10K Preparation',
    description:
        'Progress toward a confident 10K with endurance, rhythm, and recovery.',
    difficulty: TrainingDifficulty.intermediate,
    goal: 'Complete a stronger 10K',
    durationWeeks: 10,
    days: _buildPlanDays(
      weeks: 10,
      sessionsForWeek: (week) => [
        _session(
          type: TrainingSessionType.easyRun,
          distanceKm: 4.5 + (week * 0.35),
          minutes: 32 + week,
          notes: 'Relaxed aerobic volume.',
        ),
        _session(
          type: TrainingSessionType.tempo,
          distanceKm: 5.0 + (week * 0.3),
          minutes: 35 + week,
          targetPace: const Duration(minutes: 5, seconds: 20),
          notes: 'Find your efficient middle gear.',
        ),
        _session(
          type: TrainingSessionType.recovery,
          distanceKm: 3.0 + (week * 0.2),
          minutes: 25 + week,
          notes: 'Keep it light and restorative.',
        ),
        _session(
          type: TrainingSessionType.longRun,
          distanceKm: 6.5 + (week * 0.55),
          minutes: 52 + (week * 3),
          notes: 'Extend the horizon with a composed finish.',
        ),
      ],
    ),
  );

  static List<TrainingDay> _buildPlanDays({
    required int weeks,
    required List<TrainingSession> Function(int week) sessionsForWeek,
  }) {
    final days = <TrainingDay>[];
    for (var week = 1; week <= weeks; week += 1) {
      final sessions = sessionsForWeek(week);
      for (var index = 0; index < sessions.length; index += 1) {
        final session = sessions[index];
        days.add(
          TrainingDay(
            weekNumber: week,
            dayNumber: index + 1,
            title: session.type.label,
            description: _dayDescription(session.type),
            session: session,
          ),
        );
      }
    }
    return days;
  }

  static TrainingSession _session({
    required TrainingSessionType type,
    required double distanceKm,
    required int minutes,
    required String notes,
    Duration? targetPace,
  }) {
    return TrainingSession(
      type: type,
      distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
      targetPace: targetPace,
      estimatedDuration: Duration(minutes: minutes),
      notes: notes,
    );
  }

  static String _dayDescription(TrainingSessionType type) {
    return switch (type) {
      TrainingSessionType.easyRun => 'Build quiet aerobic strength.',
      TrainingSessionType.tempo => 'Practice sustained speed with control.',
      TrainingSessionType.interval => 'Sharpen pace through focused repeats.',
      TrainingSessionType.longRun => 'Stretch endurance without rushing.',
      TrainingSessionType.recovery => 'Absorb the work and stay loose.',
      TrainingSessionType.rest => 'Protect adaptation with intentional rest.',
    };
  }
}
