import 'dart:collection';

import '../entities/gps_sample_decision.dart';
import '../entities/location_point.dart';
import '../entities/run_gps_metrics.dart';
import '../entities/run_gps_signal_status.dart';
import 'geo_distance_calculator.dart';
import 'gps_point_filter.dart';
import 'gps_processing_config.dart';

class RunGpsProcessingResult {
  const RunGpsProcessingResult({required this.decision, required this.metrics});

  final GpsSampleDecision decision;
  final RunGpsMetrics metrics;
}

class RunGpsMetricsProcessor {
  RunGpsMetricsProcessor({
    GpsProcessingConfig config = const GpsProcessingConfig(),
    GeoDistanceCalculator distanceCalculator = const GeoDistanceCalculator(),
  }) : _config = config,
       _distanceCalculator = distanceCalculator,
       _filter = GpsPointFilter(
         config: config,
         distanceCalculator: distanceCalculator,
       );

  final GpsProcessingConfig _config;
  final GeoDistanceCalculator _distanceCalculator;
  final GpsPointFilter _filter;
  final Queue<double> _recentSegmentSpeeds = Queue<double>();

  RunGpsMetrics _metrics = RunGpsMetrics.zero();

  RunGpsMetrics get metrics => _metrics;

  RunGpsProcessingResult process(
    LocationPoint point, {
    required Duration movingTime,
  }) {
    final previous = _metrics.lastAcceptedPoint;
    final decision = _filter.evaluate(
      point: point,
      previousAcceptedPoint: previous,
      acceptedPointCount: _metrics.acceptedPointCount,
    );

    if (decision == GpsSampleDecision.rejectedInsufficientWarmup) {
      _recentSegmentSpeeds.clear();
      _metrics = _metrics.copyWith(
        acceptedPointCount: _metrics.acceptedPointCount + 1,
        rejectedPointCount: _metrics.rejectedPointCount + 1,
        clearCurrentSpeed: true,
        clearSmoothedSpeed: true,
        clearCurrentPace: true,
        gpsSignalStatus: RunGpsSignalStatus.searching,
        lastAcceptedPoint: point,
        lastUpdatedAt: point.recordedAt,
      );
      return RunGpsProcessingResult(decision: decision, metrics: _metrics);
    }

    if (!decision.isAccepted) {
      _metrics = _metrics.copyWith(
        rejectedPointCount: _metrics.rejectedPointCount + 1,
        gpsSignalStatus: _statusForRejected(decision),
        lastUpdatedAt: point.recordedAt,
      );
      return RunGpsProcessingResult(decision: decision, metrics: _metrics);
    }

    final segmentDistance = previous == null
        ? 0.0
        : _distanceCalculator.distanceMeters(previous, point);
    final elapsedSeconds = previous == null
        ? 0.0
        : point.recordedAt.difference(previous.recordedAt).inMilliseconds /
              1000;
    final segmentSpeed = _validSegmentSpeed(segmentDistance, elapsedSeconds);

    if (segmentSpeed != null) {
      _recentSegmentSpeeds.addLast(segmentSpeed);
      while (_recentSegmentSpeeds.length > _config.smoothingWindowSize) {
        _recentSegmentSpeeds.removeFirst();
      }
    }

    final totalDistance = _metrics.totalDistanceMeters + segmentDistance;
    final smoothedSpeed = _smoothedSpeed();
    final averageSpeed = movingTime > Duration.zero && totalDistance > 0
        ? totalDistance / (movingTime.inMilliseconds / 1000)
        : null;

    _metrics = _metrics.copyWith(
      totalDistanceMeters: totalDistance,
      currentSpeedMetersPerSecond: segmentSpeed,
      smoothedSpeedMetersPerSecond: smoothedSpeed,
      averageSpeedMetersPerSecond: averageSpeed,
      currentPaceSecondsPerKilometer: _paceForSpeed(smoothedSpeed),
      averagePaceSecondsPerKilometer: _paceForSpeed(averageSpeed),
      acceptedPointCount: _metrics.acceptedPointCount + 1,
      gpsSignalStatus: point.accuracy <= _config.maxAcceptedAccuracyMeters
          ? RunGpsSignalStatus.ready
          : RunGpsSignalStatus.weak,
      lastAcceptedPoint: point,
      lastUpdatedAt: point.recordedAt,
    );

    return RunGpsProcessingResult(decision: decision, metrics: _metrics);
  }

  void reset() {
    _metrics = RunGpsMetrics.zero();
    _recentSegmentSpeeds.clear();
  }

  void resetBaselineForResume() {
    _metrics = _metrics.copyWith(
      clearLastAcceptedPoint: true,
      clearCurrentSpeed: true,
      clearSmoothedSpeed: true,
      clearCurrentPace: true,
      gpsSignalStatus: RunGpsSignalStatus.searching,
    );
    _recentSegmentSpeeds.clear();
  }

  double? _validSegmentSpeed(double distanceMeters, double elapsedSeconds) {
    if (distanceMeters <= 0 || elapsedSeconds <= 0) {
      return null;
    }

    final derivedSpeed = distanceMeters / elapsedSeconds;
    if (!derivedSpeed.isFinite ||
        derivedSpeed < 0 ||
        derivedSpeed > _config.maxPlausibleSpeedMetersPerSecond) {
      return null;
    }
    return derivedSpeed;
  }

  double? _smoothedSpeed() {
    if (_recentSegmentSpeeds.isEmpty) {
      return null;
    }

    final total = _recentSegmentSpeeds.fold<double>(
      0,
      (sum, speed) => sum + speed,
    );
    return total / _recentSegmentSpeeds.length;
  }

  double? _paceForSpeed(double? speedMetersPerSecond) {
    final speed = speedMetersPerSecond;
    if (speed == null ||
        !speed.isFinite ||
        speed < _config.minimumPaceSpeedMetersPerSecond) {
      return null;
    }
    return 1000 / speed;
  }

  RunGpsSignalStatus _statusForRejected(GpsSampleDecision decision) {
    return switch (decision) {
      GpsSampleDecision.rejectedAccuracy ||
      GpsSampleDecision.rejectedImpossibleJump => RunGpsSignalStatus.weak,
      GpsSampleDecision.rejectedTimestamp ||
      GpsSampleDecision.rejectedDuplicate ||
      GpsSampleDecision.rejectedStationaryNoise ||
      GpsSampleDecision.rejectedInsufficientWarmup =>
        _metrics.acceptedPointCount == 0
            ? RunGpsSignalStatus.searching
            : RunGpsSignalStatus.ready,
      GpsSampleDecision.accepted => RunGpsSignalStatus.ready,
    };
  }
}
