import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/features/ai_coach/domain/entities/run_analysis.dart';
import 'package:kyven_mobile/features/ai_coach/domain/services/run_analysis_engine.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_route.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_route_point.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_route_segment.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/saved_run.dart';

void main() {
  const engine = RuleBasedRunAnalysisEngine();

  SavedRun runFixture({
    required List<int> paceSecondsPerKm,
    double distanceKm = 5,
    Duration? duration,
  }) {
    final startedAt = DateTime(2026, 7, 21, 7);
    final points = <RunRoutePoint>[
      RunRoutePoint(latitude: 25, longitude: 55, timestamp: startedAt),
    ];

    for (final pace in paceSecondsPerKm) {
      final previous = points.last;
      points.add(
        RunRoutePoint(
          latitude: previous.latitude + 0.008993216,
          longitude: previous.longitude,
          timestamp: previous.timestamp.add(Duration(seconds: pace)),
        ),
      );
    }

    final elapsed =
        duration ??
        Duration(
          seconds: paceSecondsPerKm.fold<int>(
            0,
            (total, seconds) => total + seconds,
          ),
        );

    return SavedRun(
      id: 'analysis-run',
      startedAt: startedAt,
      completedAt: startedAt.add(elapsed),
      duration: elapsed,
      distanceKm: distanceKm,
      averagePace: paceSecondsPerKm.isEmpty
          ? Duration.zero
          : Duration(
              seconds:
                  paceSecondsPerKm.reduce(
                    (value, element) => value + element,
                  ) ~/
                  paceSecondsPerKm.length,
            ),
      calories: 320,
      cadence: 168,
      averageHeartRate: 142,
      routePreview: '',
      achievement: '',
      route: RunRoute(
        segments: [RunRouteSegment(points: points, isOpen: false)],
      ),
    );
  }

  test('calculates a bounded weighted score', () {
    final analysis = engine.analyze(
      runFixture(paceSecondsPerKm: [300, 300, 300, 300]),
    );

    expect(analysis.performanceScore, 93);
    expect(analysis.performanceScore, inInclusiveRange(0, 100));
  });

  test('maps score to rating thresholds', () {
    final exceptional = engine.analyze(
      runFixture(paceSecondsPerKm: [300, 300, 300, 300]),
    );
    final recoveryFocus = engine.analyze(
      runFixture(paceSecondsPerKm: [240, 260, 420, 480]),
    );

    expect(exceptional.performanceRating, PerformanceRating.exceptional);
    expect(recoveryFocus.performanceRating, PerformanceRating.recoveryFocus);
  });

  test('detects excellent and poor pace consistency', () {
    final excellent = engine.analyze(
      runFixture(paceSecondsPerKm: [300, 300, 300, 300]),
    );
    final poor = engine.analyze(
      runFixture(paceSecondsPerKm: [240, 260, 420, 480]),
    );

    expect(excellent.paceConsistency, PaceConsistency.excellent);
    expect(poor.paceConsistency, PaceConsistency.poor);
  });

  test('detects high fatigue from late slowdown', () {
    final analysis = engine.analyze(
      runFixture(paceSecondsPerKm: [260, 265, 430, 470]),
    );

    expect(analysis.fatigueLevel, FatigueLevel.high);
  });

  test('detects negative split when the finish is faster', () {
    final analysis = engine.analyze(
      runFixture(paceSecondsPerKm: [360, 340, 300, 280]),
    );

    expect(analysis.negativeSplitResult, NegativeSplitResult.achieved);
  });

  test('generates only relevant coach tips', () {
    final analysis = engine.analyze(
      runFixture(paceSecondsPerKm: [240, 260, 420, 480]),
    );

    expect(
      analysis.coachTips,
      contains('Avoid starting too fast; settle into your target pace early.'),
    );
    expect(
      analysis.coachTips,
      contains('Build endurance gradually and leave energy for the finish.'),
    );
    expect(
      analysis.coachTips,
      isNot(contains('Great negative split — your finish was controlled.')),
    );
  });

  test('generates deterministic summary text', () {
    final analysis = engine.analyze(
      runFixture(paceSecondsPerKm: [300, 300, 300, 300]),
    );

    expect(
      analysis.summaryText,
      'Exceptional run with excellent pacing and a composed finish. '
      'Your halves stayed balanced.',
    );
  });

  test('adapts recovery recommendation for very short runs', () {
    final analysis = engine.analyze(
      runFixture(
        paceSecondsPerKm: [300],
        distanceKm: 0.7,
        duration: const Duration(minutes: 5),
      ),
    );

    expect(
      analysis.recoveryRecommendation,
      RecoveryRecommendation.buildGradually,
    );
    expect(
      analysis.coachTips,
      contains('Increase distance gradually before adding intensity.'),
    );
  });
}
