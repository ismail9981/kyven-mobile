import '../../domain/entities/training_plan.dart';
import '../../domain/entities/training_session.dart';

extension TrainingPlanFormatters on TrainingPlan {
  String get primarySessionTypesLabel {
    final labels = days
        .map((day) => day.session.type.label)
        .toSet()
        .take(3)
        .join(' · ');
    return labels.isEmpty ? 'Structured sessions' : labels;
  }
}

extension TrainingDurationFormatters on Duration {
  String get trainingDurationLabel {
    final minutes = inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}m';
  }
}

extension TrainingPaceFormatters on Duration {
  String get trainingPaceLabel {
    final minutes = inMinutes;
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds /km';
  }
}

extension TrainingSessionFormatters on TrainingSession {
  String get distanceLabel {
    if (type == TrainingSessionType.rest || distanceKm <= 0) {
      return 'Rest';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}
