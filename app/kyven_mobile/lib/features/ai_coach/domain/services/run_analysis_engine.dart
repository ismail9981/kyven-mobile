import 'dart:math' as math;

import '../../../run_tracking/domain/entities/location_point.dart';
import '../../../run_tracking/domain/entities/run_route_point.dart';
import '../../../run_tracking/domain/entities/saved_run.dart';
import '../../../run_tracking/domain/services/geo_distance_calculator.dart';
import '../entities/run_analysis.dart';

abstract interface class RunAnalysisEngine {
  RunAnalysis analyze(SavedRun run);
}

class RuleBasedRunAnalysisEngine implements RunAnalysisEngine {
  const RuleBasedRunAnalysisEngine({
    this._distanceCalculator = const GeoDistanceCalculator(),
  });

  static const _minimumRouteLegMeters = 8.0;
  static const _splitTolerance = 0.03;

  final GeoDistanceCalculator _distanceCalculator;

  @override
  RunAnalysis analyze(SavedRun run) {
    final paces = _routePaces(run);
    final split = _splitProfile(paces);
    final consistency = _paceConsistency(paces);
    final fatigue = _fatigueLevel(split);
    final negativeSplit = _negativeSplit(split);
    final recommendation = _recoveryRecommendation(
      run: run,
      fatigueLevel: fatigue,
    );
    final score = _performanceScore(
      run: run,
      paceConsistency: consistency,
      fatigueLevel: fatigue,
      negativeSplitResult: negativeSplit,
    );
    final rating = _performanceRating(score);
    final tips = _coachTips(
      run: run,
      paceConsistency: consistency,
      fatigueLevel: fatigue,
      negativeSplitResult: negativeSplit,
    );

    return RunAnalysis(
      performanceScore: score,
      performanceRating: rating,
      paceConsistency: consistency,
      fatigueLevel: fatigue,
      negativeSplitResult: negativeSplit,
      recoveryRecommendation: recommendation,
      coachTips: tips,
      summaryText: _summaryText(
        rating: rating,
        paceConsistency: consistency,
        fatigueLevel: fatigue,
        negativeSplitResult: negativeSplit,
      ),
    );
  }

  List<double> _routePaces(SavedRun run) {
    final paces = <double>[];

    for (final segment in run.route.segments) {
      final points = segment.points;
      for (var index = 1; index < points.length; index += 1) {
        final previous = points[index - 1];
        final current = points[index];
        final seconds = current.timestamp
            .difference(previous.timestamp)
            .inSeconds;
        if (seconds <= 0) {
          continue;
        }

        final meters = _distanceCalculator.distanceMeters(
          _locationPoint(previous),
          _locationPoint(current),
        );
        if (meters < _minimumRouteLegMeters) {
          continue;
        }

        paces.add(seconds / (meters / 1000));
      }
    }

    return paces;
  }

  PaceConsistency _paceConsistency(List<double> paces) {
    if (paces.length < 2) {
      return PaceConsistency.unavailable;
    }

    final mean = _mean(paces);
    if (mean <= 0) {
      return PaceConsistency.unavailable;
    }

    final variance =
        paces
            .map((pace) => math.pow(pace - mean, 2))
            .reduce((value, element) => value + element) /
        paces.length;
    final coefficientOfVariation = math.sqrt(variance) / mean;

    if (coefficientOfVariation <= 0.05) {
      return PaceConsistency.excellent;
    }
    if (coefficientOfVariation <= 0.10) {
      return PaceConsistency.good;
    }
    if (coefficientOfVariation <= 0.18) {
      return PaceConsistency.moderate;
    }
    return PaceConsistency.poor;
  }

  _SplitProfile _splitProfile(List<double> paces) {
    if (paces.length < 2) {
      return const _SplitProfile.unavailable();
    }

    final midpoint = paces.length ~/ 2;
    final firstHalf = paces.take(midpoint).toList(growable: false);
    final secondHalf = paces.skip(midpoint).toList(growable: false);

    return _SplitProfile(
      firstHalfPaceSecondsPerKm: _mean(firstHalf),
      secondHalfPaceSecondsPerKm: _mean(secondHalf),
    );
  }

  FatigueLevel _fatigueLevel(_SplitProfile split) {
    if (!split.isAvailable) {
      return FatigueLevel.unavailable;
    }

    final slowdown = split.slowdownRatio;
    if (slowdown <= 0.03) {
      return FatigueLevel.low;
    }
    if (slowdown <= 0.10) {
      return FatigueLevel.moderate;
    }
    return FatigueLevel.high;
  }

  NegativeSplitResult _negativeSplit(_SplitProfile split) {
    if (!split.isAvailable) {
      return NegativeSplitResult.unavailable;
    }

    final slowdown = split.slowdownRatio;
    if (slowdown < -_splitTolerance) {
      return NegativeSplitResult.achieved;
    }
    if (slowdown.abs() <= _splitTolerance) {
      return NegativeSplitResult.even;
    }
    return NegativeSplitResult.missed;
  }

  RecoveryRecommendation _recoveryRecommendation({
    required SavedRun run,
    required FatigueLevel fatigueLevel,
  }) {
    if (run.distanceKm < 1) {
      return RecoveryRecommendation.buildGradually;
    }
    if (fatigueLevel == FatigueLevel.high) {
      return RecoveryRecommendation.restAndReset;
    }
    if (run.distanceKm >= 10) {
      return RecoveryRecommendation.easyRecovery;
    }
    return RecoveryRecommendation.normalTraining;
  }

  int _performanceScore({
    required SavedRun run,
    required PaceConsistency paceConsistency,
    required FatigueLevel fatigueLevel,
    required NegativeSplitResult negativeSplitResult,
  }) {
    final consistencyScore = switch (paceConsistency) {
      PaceConsistency.excellent => 100,
      PaceConsistency.good => 82,
      PaceConsistency.moderate => 62,
      PaceConsistency.poor => 35,
      PaceConsistency.unavailable => 60,
    };
    final fatigueScore = switch (fatigueLevel) {
      FatigueLevel.low => 100,
      FatigueLevel.moderate => 70,
      FatigueLevel.high => 35,
      FatigueLevel.unavailable => 65,
    };
    final splitScore = switch (negativeSplitResult) {
      NegativeSplitResult.achieved => 100,
      NegativeSplitResult.even => 78,
      NegativeSplitResult.missed => 45,
      NegativeSplitResult.unavailable => 65,
    };
    final enduranceScore = _enduranceScore(run.distanceKm);

    final weightedScore =
        (consistencyScore * 0.35) +
        (fatigueScore * 0.25) +
        (splitScore * 0.20) +
        (enduranceScore * 0.20);

    return weightedScore.round().clamp(0, 100);
  }

  int _enduranceScore(double distanceKm) {
    if (distanceKm >= 10) {
      return 95;
    }
    if (distanceKm >= 5) {
      return 85;
    }
    if (distanceKm >= 3) {
      return 72;
    }
    if (distanceKm >= 1) {
      return 60;
    }
    return 45;
  }

  PerformanceRating _performanceRating(int score) {
    if (score >= 90) {
      return PerformanceRating.exceptional;
    }
    if (score >= 80) {
      return PerformanceRating.excellent;
    }
    if (score >= 68) {
      return PerformanceRating.strong;
    }
    if (score >= 50) {
      return PerformanceRating.steady;
    }
    return PerformanceRating.recoveryFocus;
  }

  List<String> _coachTips({
    required SavedRun run,
    required PaceConsistency paceConsistency,
    required FatigueLevel fatigueLevel,
    required NegativeSplitResult negativeSplitResult,
  }) {
    final tips = <String>[];

    switch (paceConsistency) {
      case PaceConsistency.excellent:
        tips.add('Excellent pacing — keep this rhythm.');
      case PaceConsistency.good:
        tips.add('Your pacing was controlled. Keep settling in early.');
      case PaceConsistency.moderate:
        tips.add('Smooth the middle section before increasing intensity.');
      case PaceConsistency.poor:
        tips.add(
          'Avoid starting too fast; settle into your target pace early.',
        );
      case PaceConsistency.unavailable:
        tips.add('Record a little more route data for deeper pace feedback.');
    }

    switch (fatigueLevel) {
      case FatigueLevel.high:
        tips.add('Build endurance gradually and leave energy for the finish.');
        tips.add('Keep hydration consistent before your next effort.');
      case FatigueLevel.moderate:
        tips.add('Hold back slightly in the first half to protect the finish.');
      case FatigueLevel.low:
        tips.add('Your finish stayed composed. Maintain this effort pattern.');
      case FatigueLevel.unavailable:
        break;
    }

    switch (negativeSplitResult) {
      case NegativeSplitResult.achieved:
        tips.add('Great negative split — your finish was controlled.');
      case NegativeSplitResult.missed:
        tips.add('Aim to finish the final third as strong as the first.');
      case NegativeSplitResult.even:
        tips.add('Even pacing is a strong base for future speed work.');
      case NegativeSplitResult.unavailable:
        break;
    }

    if (run.distanceKm < 1) {
      tips.add('Increase distance gradually before adding intensity.');
    } else if (run.distanceKm >= 10) {
      tips.add('Prioritize an easy recovery effort after this long run.');
    }

    return tips.take(4).toList(growable: false);
  }

  String _summaryText({
    required PerformanceRating rating,
    required PaceConsistency paceConsistency,
    required FatigueLevel fatigueLevel,
    required NegativeSplitResult negativeSplitResult,
  }) {
    final pacing = switch (paceConsistency) {
      PaceConsistency.excellent => 'excellent pacing',
      PaceConsistency.good => 'controlled pacing',
      PaceConsistency.moderate => 'some pace movement',
      PaceConsistency.poor => 'uneven pacing',
      PaceConsistency.unavailable => 'limited route data',
    };
    final fatigue = switch (fatigueLevel) {
      FatigueLevel.low => 'a composed finish',
      FatigueLevel.moderate => 'manageable fatigue',
      FatigueLevel.high => 'clear late fatigue',
      FatigueLevel.unavailable => 'limited fatigue data',
    };
    final split = switch (negativeSplitResult) {
      NegativeSplitResult.achieved => 'You finished faster than you started.',
      NegativeSplitResult.even => 'Your halves stayed balanced.',
      NegativeSplitResult.missed =>
        'Your finish slowed compared with the start.',
      NegativeSplitResult.unavailable =>
        'KYVEN will refine the split once more route data is available.',
    };

    return '${rating.label} run with $pacing and $fatigue. $split';
  }

  double _mean(List<double> values) =>
      values.reduce((value, element) => value + element) / values.length;

  LocationPoint _locationPoint(RunRoutePoint point) {
    return LocationPoint(
      latitude: point.latitude,
      longitude: point.longitude,
      accuracy: 0,
      recordedAt: point.timestamp,
    );
  }
}

class _SplitProfile {
  const _SplitProfile({
    required this.firstHalfPaceSecondsPerKm,
    required this.secondHalfPaceSecondsPerKm,
  });

  const _SplitProfile.unavailable()
    : firstHalfPaceSecondsPerKm = null,
      secondHalfPaceSecondsPerKm = null;

  final double? firstHalfPaceSecondsPerKm;
  final double? secondHalfPaceSecondsPerKm;

  bool get isAvailable =>
      firstHalfPaceSecondsPerKm != null && secondHalfPaceSecondsPerKm != null;

  double get slowdownRatio {
    final firstHalf = firstHalfPaceSecondsPerKm;
    final secondHalf = secondHalfPaceSecondsPerKm;
    if (firstHalf == null || secondHalf == null || firstHalf <= 0) {
      return 0;
    }
    return (secondHalf - firstHalf) / firstHalf;
  }
}
