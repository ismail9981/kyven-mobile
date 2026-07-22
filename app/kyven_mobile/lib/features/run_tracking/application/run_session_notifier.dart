import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/gps_sample_decision.dart';
import '../domain/entities/location_point.dart';
import '../domain/entities/run_metrics.dart';
import '../domain/entities/run_route.dart';
import '../domain/entities/run_route_point.dart';
import '../domain/entities/run_session.dart';
import '../domain/entities/run_summary.dart';
import '../domain/services/run_gps_metrics_processor.dart';
import 'run_session_state.dart';

class RunSessionNotifier extends Notifier<RunSessionState> {
  final _gpsProcessor = RunGpsMetricsProcessor();
  Timer? _timer;
  DateTime? _pausedAt;

  @override
  RunSessionState build() {
    ref.onDispose(_stopTimer);
    return const RunSessionState();
  }

  void prepare() {
    if (state.status != RunSessionStatus.idle &&
        state.status != RunSessionStatus.completed) {
      return;
    }

    _stopTimer();
    _gpsProcessor.reset();
    _pausedAt = null;
    state = RunSessionState(
      status: RunSessionStatus.preparing,
      session: RunSession(
        id: 'local-run-${DateTime.now().millisecondsSinceEpoch}',
        startedAt: DateTime.now(),
        metrics: RunMetrics.zero(),
        route: RunRoute.empty(),
      ),
    );
  }

  void start() {
    if (state.status == RunSessionStatus.idle ||
        state.status == RunSessionStatus.completed) {
      prepare();
    }
    if (state.status != RunSessionStatus.preparing) return;

    state = state.copyWith(
      status: RunSessionStatus.running,
      clearSummary: true,
    );
    _startTimer();
  }

  void tick([Duration delta = const Duration(seconds: 1)]) {
    if (state.status != RunSessionStatus.running || delta <= Duration.zero) {
      return;
    }

    final session = state.session;
    if (session == null) return;

    final previous = session.metrics;
    final elapsed = previous.elapsed + delta;
    final movingTime = previous.movingTime + delta;
    final elapsedSeconds = elapsed.inSeconds;
    final distanceKm = previous.gps.totalDistanceMeters / 1000;

    final metrics = previous.copyWith(
      elapsed: elapsed,
      movingTime: movingTime,
      distanceKm: distanceKm,
      calories: (distanceKm * 68).round().clamp(0, 9999),
      cadence: 166 + (elapsedSeconds % 7),
      heartRate: 136 + (elapsedSeconds % 13),
    );

    state = state.copyWith(session: session.copyWith(metrics: metrics));
  }

  GpsSampleDecision? processLocationPoint(LocationPoint point) {
    if (state.status != RunSessionStatus.running) {
      return null;
    }

    final session = state.session;
    if (session == null) {
      return null;
    }

    final result = _gpsProcessor.process(
      point,
      movingTime: session.metrics.movingTime,
    );
    final gps = result.metrics;
    final currentPaceSeconds = gps.currentPaceSecondsPerKilometer;
    final averagePaceSeconds = gps.averagePaceSecondsPerKilometer;
    final metrics = session.metrics.copyWith(
      gps: gps,
      distanceKm: gps.totalDistanceMeters / 1000,
      currentSpeedMetersPerSecond: gps.smoothedSpeedMetersPerSecond,
      currentPace: currentPaceSeconds == null
          ? Duration.zero
          : Duration(seconds: currentPaceSeconds.round()),
      averagePace: averagePaceSeconds == null
          ? Duration.zero
          : Duration(seconds: averagePaceSeconds.round()),
      calories: ((gps.totalDistanceMeters / 1000) * 68).round().clamp(0, 9999),
    );
    final route = result.decision.isAccepted
        ? session.route.appendPoint(RunRoutePoint.fromLocationPoint(point))
        : session.route;
    state = state.copyWith(
      session: session.copyWith(metrics: metrics, route: route),
    );
    return result.decision;
  }

  void pause() {
    if (state.status != RunSessionStatus.running) return;
    _stopTimer();
    _pausedAt = DateTime.now();
    state = state.copyWith(
      status: RunSessionStatus.paused,
      session: state.session?.copyWith(
        route: state.session?.route.closeActiveSegment(),
      ),
    );
  }

  void resume() {
    if (state.status != RunSessionStatus.paused) return;
    _gpsProcessor.resetBaselineForResume();
    final session = state.session;
    final pauseDuration = _consumePauseDuration();
    if (session != null) {
      final metrics = session.metrics;
      state = state.copyWith(
        session: session.copyWith(
          metrics: metrics.copyWith(
            elapsed: metrics.elapsed + pauseDuration,
            pausedTime: metrics.pausedTime + pauseDuration,
            gps: _gpsProcessor.metrics,
            currentPace: Duration.zero,
            clearCurrentSpeed: true,
          ),
        ),
      );
    }
    state = state.copyWith(status: RunSessionStatus.running);
    _startTimer();
  }

  void requestFinish() {
    if (state.status != RunSessionStatus.running &&
        state.status != RunSessionStatus.paused) {
      return;
    }
    _stopTimer();
    state = state.copyWith(
      status: RunSessionStatus.finishing,
      session: state.status == RunSessionStatus.paused
          ? _sessionWithConsumedPauseDuration(state.session)
          : state.session?.copyWith(
              route: state.session?.route.closeActiveSegment(),
            ),
    );
  }

  void cancelFinish() {
    if (state.status != RunSessionStatus.finishing) return;
    _pausedAt = DateTime.now();
    state = state.copyWith(status: RunSessionStatus.paused);
  }

  void completeFinish() {
    if (state.status != RunSessionStatus.finishing) return;
    final session = state.session;
    if (session == null) return;
    final completedSession = session.copyWith(
      route: session.route.closeActiveSegment(),
    );

    state = state.copyWith(
      status: RunSessionStatus.completed,
      session: completedSession,
      summary: RunSummary(
        completedAt: DateTime.now(),
        metrics: completedSession.metrics,
        achievement: _achievementFor(completedSession.metrics),
      ),
    );
  }

  void reset() {
    _stopTimer();
    _gpsProcessor.reset();
    _pausedAt = null;
    state = const RunSessionState();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Duration _consumePauseDuration() {
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt == null) {
      return Duration.zero;
    }
    final duration = DateTime.now().difference(pausedAt);
    return duration.isNegative ? Duration.zero : duration;
  }

  RunSession? _sessionWithConsumedPauseDuration(RunSession? session) {
    if (session == null) {
      _pausedAt = null;
      return null;
    }
    final pauseDuration = _consumePauseDuration();
    if (pauseDuration <= Duration.zero) {
      return session.copyWith(route: session.route.closeActiveSegment());
    }
    final metrics = session.metrics;
    return session.copyWith(
      route: session.route.closeActiveSegment(),
      metrics: metrics.copyWith(
        elapsed: metrics.elapsed + pauseDuration,
        pausedTime: metrics.pausedTime + pauseDuration,
      ),
    );
  }

  String _achievementFor(RunMetrics metrics) {
    if (metrics.distanceKm >= 5) return 'Motion Path expanded';
    if (metrics.elapsed.inMinutes >= 20) return 'Consistency builder';
    return 'First movement logged';
  }
}
