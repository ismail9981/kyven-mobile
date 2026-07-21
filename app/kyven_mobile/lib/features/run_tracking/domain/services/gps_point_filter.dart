import '../entities/gps_sample_decision.dart';
import '../entities/location_point.dart';
import 'geo_distance_calculator.dart';
import 'gps_processing_config.dart';

class GpsPointFilter {
  const GpsPointFilter({
    this.config = const GpsProcessingConfig(),
    this.distanceCalculator = const GeoDistanceCalculator(),
  });

  final GpsProcessingConfig config;
  final GeoDistanceCalculator distanceCalculator;

  GpsSampleDecision evaluate({
    required LocationPoint point,
    required LocationPoint? previousAcceptedPoint,
    required int acceptedPointCount,
  }) {
    if (!_hasValidCoordinates(point)) {
      return GpsSampleDecision.rejectedAccuracy;
    }

    if (!point.accuracy.isFinite ||
        point.accuracy <= 0 ||
        point.accuracy > config.maxAcceptedAccuracyMeters) {
      return GpsSampleDecision.rejectedAccuracy;
    }

    final previous = previousAcceptedPoint;
    if (previous == null) {
      return GpsSampleDecision.accepted;
    }

    if (point.latitude == previous.latitude &&
        point.longitude == previous.longitude) {
      return GpsSampleDecision.rejectedDuplicate;
    }

    if (!point.recordedAt.isAfter(previous.recordedAt)) {
      return GpsSampleDecision.rejectedTimestamp;
    }

    final elapsedSeconds =
        point.recordedAt.difference(previous.recordedAt).inMilliseconds / 1000;
    if (elapsedSeconds <= 0) {
      return GpsSampleDecision.rejectedTimestamp;
    }

    final distanceMeters = distanceCalculator.distanceMeters(previous, point);
    final segmentSpeed = distanceMeters / elapsedSeconds;

    if (!segmentSpeed.isFinite ||
        segmentSpeed > config.maxPlausibleSpeedMetersPerSecond) {
      return GpsSampleDecision.rejectedImpossibleJump;
    }

    if (acceptedPointCount < config.warmupAcceptedPointCount) {
      return GpsSampleDecision.rejectedInsufficientWarmup;
    }

    final movementThreshold = _movementThreshold(previous, point);
    final rawSpeed = point.speed;
    final isStationaryByRawSpeed =
        rawSpeed != null &&
        rawSpeed.isFinite &&
        rawSpeed >= 0 &&
        rawSpeed < config.stationarySpeedThresholdMetersPerSecond;
    if (distanceMeters < movementThreshold ||
        (isStationaryByRawSpeed && distanceMeters < movementThreshold * 1.5)) {
      return GpsSampleDecision.rejectedStationaryNoise;
    }

    return GpsSampleDecision.accepted;
  }

  double _movementThreshold(LocationPoint previous, LocationPoint point) {
    final accuracyNoise = (previous.accuracy + point.accuracy) * 0.25;
    return accuracyNoise > config.minimumMovementMeters
        ? accuracyNoise
        : config.minimumMovementMeters;
  }

  bool _hasValidCoordinates(LocationPoint point) {
    return point.latitude.isFinite &&
        point.longitude.isFinite &&
        point.latitude >= -90 &&
        point.latitude <= 90 &&
        point.longitude >= -180 &&
        point.longitude <= 180;
  }
}
