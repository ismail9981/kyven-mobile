import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/gps_sample_decision.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/location_point.dart';
import 'package:kyven_mobile/features/run_tracking/domain/services/geo_distance_calculator.dart';
import 'package:kyven_mobile/features/run_tracking/domain/services/gps_point_filter.dart';
import 'package:kyven_mobile/features/run_tracking/domain/services/gps_processing_config.dart';
import 'package:kyven_mobile/features/run_tracking/domain/services/run_gps_metrics_processor.dart';

void main() {
  LocationPoint point({
    required double latitude,
    required double longitude,
    required int seconds,
    double accuracy = 8,
    double? speed,
  }) {
    return LocationPoint(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      speed: speed,
      recordedAt: DateTime(2026, 7, 21, 7, 0, seconds),
    );
  }

  group('GeoDistanceCalculator', () {
    const calculator = GeoDistanceCalculator();

    test('identical coordinates return zero', () {
      final sample = point(latitude: 25.2048, longitude: 55.2708, seconds: 0);

      expect(calculator.distanceMeters(sample, sample), 0);
    });

    test('known coordinate pair produces expected distance', () {
      final start = point(latitude: 0, longitude: 0, seconds: 0);
      final end = point(latitude: 0, longitude: 1, seconds: 10);

      expect(calculator.distanceMeters(start, end), closeTo(111195, 75));
    });

    test('short-distance calculations are stable', () {
      final start = point(latitude: 25.2048, longitude: 55.2708, seconds: 0);
      final end = point(latitude: 25.20489, longitude: 55.2708, seconds: 10);

      expect(calculator.distanceMeters(start, end), closeTo(10, 1.2));
    });
  });

  group('GpsPointFilter', () {
    const filter = GpsPointFilter(
      config: GpsProcessingConfig(warmupAcceptedPointCount: 1),
    );
    final baseline = point(latitude: 25.2048, longitude: 55.2708, seconds: 0);

    test('first point becomes baseline only', () {
      expect(
        filter.evaluate(
          point: baseline,
          previousAcceptedPoint: null,
          acceptedPointCount: 0,
        ),
        GpsSampleDecision.accepted,
      );
    });

    test('poor accuracy is rejected', () {
      final sample = point(
        latitude: 25.2049,
        longitude: 55.2708,
        seconds: 5,
        accuracy: 60,
      );

      expect(
        filter.evaluate(
          point: sample,
          previousAcceptedPoint: baseline,
          acceptedPointCount: 1,
        ),
        GpsSampleDecision.rejectedAccuracy,
      );
    });

    test('duplicate point is rejected', () {
      expect(
        filter.evaluate(
          point: baseline,
          previousAcceptedPoint: baseline,
          acceptedPointCount: 1,
        ),
        GpsSampleDecision.rejectedDuplicate,
      );
    });

    test('old timestamp is rejected', () {
      final sample = point(latitude: 25.205, longitude: 55.2708, seconds: -1);

      expect(
        filter.evaluate(
          point: sample,
          previousAcceptedPoint: baseline,
          acceptedPointCount: 1,
        ),
        GpsSampleDecision.rejectedTimestamp,
      );
    });

    test('impossible jump is rejected', () {
      final sample = point(latitude: 25.3, longitude: 55.2708, seconds: 3);

      expect(
        filter.evaluate(
          point: sample,
          previousAcceptedPoint: baseline,
          acceptedPointCount: 1,
        ),
        GpsSampleDecision.rejectedImpossibleJump,
      );
    });

    test('stationary drift is rejected', () {
      final sample = point(
        latitude: 25.204805,
        longitude: 55.2708,
        seconds: 5,
        speed: 0.1,
      );

      expect(
        filter.evaluate(
          point: sample,
          previousAcceptedPoint: baseline,
          acceptedPointCount: 1,
        ),
        GpsSampleDecision.rejectedStationaryNoise,
      );
    });

    test('valid running point is accepted after warmup', () {
      final sample = point(latitude: 25.20495, longitude: 55.2708, seconds: 8);

      expect(
        filter.evaluate(
          point: sample,
          previousAcceptedPoint: baseline,
          acceptedPointCount: 1,
        ),
        GpsSampleDecision.accepted,
      );
    });

    test('warmup behavior can reject until enough accepted points exist', () {
      const warmupFilter = GpsPointFilter(
        config: GpsProcessingConfig(warmupAcceptedPointCount: 2),
      );
      final sample = point(latitude: 25.20495, longitude: 55.2708, seconds: 8);

      expect(
        warmupFilter.evaluate(
          point: sample,
          previousAcceptedPoint: baseline,
          acceptedPointCount: 1,
        ),
        GpsSampleDecision.rejectedInsufficientWarmup,
      );
    });
  });

  group('RunGpsMetricsProcessor', () {
    test('accepted points increase total distance and speed', () {
      final processor = RunGpsMetricsProcessor();
      final first = point(latitude: 25.2048, longitude: 55.2708, seconds: 0);
      final second = point(latitude: 25.20498, longitude: 55.2708, seconds: 10);

      expect(
        processor.process(first, movingTime: Duration.zero).decision,
        GpsSampleDecision.accepted,
      );
      final result = processor.process(
        second,
        movingTime: const Duration(seconds: 10),
      );

      expect(result.decision, GpsSampleDecision.accepted);
      expect(result.metrics.totalDistanceMeters, closeTo(20, 2));
      expect(result.metrics.currentSpeedMetersPerSecond, closeTo(2, 0.25));
      expect(result.metrics.averagePaceSecondsPerKilometer, closeTo(500, 55));
    });

    test('rejection does not alter distance', () {
      final processor = RunGpsMetricsProcessor();
      final first = point(latitude: 25.2048, longitude: 55.2708, seconds: 0);
      final bad = point(
        latitude: 25.205,
        longitude: 55.2708,
        seconds: 5,
        accuracy: 90,
      );

      processor.process(first, movingTime: Duration.zero);
      final result = processor.process(
        bad,
        movingTime: const Duration(seconds: 5),
      );

      expect(result.decision, GpsSampleDecision.rejectedAccuracy);
      expect(result.metrics.totalDistanceMeters, 0);
      expect(result.metrics.rejectedPointCount, 1);
    });

    test('smoothing reduces sudden speed spikes', () {
      final processor = RunGpsMetricsProcessor(
        config: const GpsProcessingConfig(smoothingWindowSize: 3),
      );
      processor.process(
        point(latitude: 25.2048, longitude: 55.2708, seconds: 0),
        movingTime: Duration.zero,
      );
      processor.process(
        point(latitude: 25.20498, longitude: 55.2708, seconds: 10),
        movingTime: const Duration(seconds: 10),
      );
      final spike = processor.process(
        point(latitude: 25.20535, longitude: 55.2708, seconds: 15),
        movingTime: const Duration(seconds: 15),
      );

      expect(
        spike.metrics.smoothedSpeedMetersPerSecond,
        lessThan(spike.metrics.currentSpeedMetersPerSecond!),
      );
    });

    test('zero or low speed returns unavailable pace', () {
      final processor = RunGpsMetricsProcessor();
      final first = point(latitude: 25.2048, longitude: 55.2708, seconds: 0);
      final drift = point(latitude: 25.204805, longitude: 55.2708, seconds: 20);

      processor.process(first, movingTime: Duration.zero);
      final result = processor.process(
        drift,
        movingTime: const Duration(seconds: 20),
      );

      expect(result.decision, GpsSampleDecision.rejectedStationaryNoise);
      expect(result.metrics.currentPaceSecondsPerKilometer, isNull);
    });
  });
}
