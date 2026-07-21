class GpsProcessingConfig {
  const GpsProcessingConfig({
    this.maxAcceptedAccuracyMeters = 25,
    this.maxPlausibleSpeedMetersPerSecond = 12,
    this.minimumMovementMeters = 6,
    this.stationarySpeedThresholdMetersPerSecond = 0.45,
    this.warmupAcceptedPointCount = 1,
    this.smoothingWindowSize = 4,
    this.minimumPaceSpeedMetersPerSecond = 0.5,
  });

  final double maxAcceptedAccuracyMeters;
  final double maxPlausibleSpeedMetersPerSecond;
  final double minimumMovementMeters;
  final double minimumPaceSpeedMetersPerSecond;
  final int smoothingWindowSize;
  final double stationarySpeedThresholdMetersPerSecond;
  final int warmupAcceptedPointCount;
}
