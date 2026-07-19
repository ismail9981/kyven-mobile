import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/run_metrics.dart';
import '../domain/entities/run_session.dart';
import '../domain/entities/run_summary.dart';
import 'run_session_state.dart';

class RunSessionNotifier extends Notifier<RunSessionState> {
  Timer? _timer;

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
    state = RunSessionState(
      status: RunSessionStatus.preparing,
      session: RunSession(
        id: 'local-run-${DateTime.now().millisecondsSinceEpoch}',
        startedAt: DateTime.now(),
        metrics: RunMetrics.zero(),
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
    final elapsedSeconds = elapsed.inSeconds;
    final paceSeconds = 330 + ((elapsedSeconds % 9) - 4) * 3;
    final safePaceSeconds = paceSeconds.clamp(300, 375);
    final distanceDelta = delta.inMilliseconds / 1000 / safePaceSeconds;
    final distanceKm = (previous.distanceKm + distanceDelta).clamp(
      0,
      double.infinity,
    );
    final averagePaceSeconds = distanceKm == 0
        ? 0
        : elapsed.inSeconds / distanceKm;

    final metrics = previous.copyWith(
      elapsed: elapsed,
      distanceKm: distanceKm.toDouble(),
      currentPace: Duration(seconds: safePaceSeconds.toInt()),
      averagePace: Duration(seconds: averagePaceSeconds.round()),
      calories: (distanceKm * 68).round().clamp(0, 9999),
      cadence: 166 + (elapsedSeconds % 7),
      heartRate: 136 + (elapsedSeconds % 13),
    );

    state = state.copyWith(session: session.copyWith(metrics: metrics));
  }

  void pause() {
    if (state.status != RunSessionStatus.running) return;
    _stopTimer();
    state = state.copyWith(status: RunSessionStatus.paused);
  }

  void resume() {
    if (state.status != RunSessionStatus.paused) return;
    state = state.copyWith(status: RunSessionStatus.running);
    _startTimer();
  }

  void requestFinish() {
    if (state.status != RunSessionStatus.running &&
        state.status != RunSessionStatus.paused) {
      return;
    }
    _stopTimer();
    state = state.copyWith(status: RunSessionStatus.finishing);
  }

  void cancelFinish() {
    if (state.status != RunSessionStatus.finishing) return;
    state = state.copyWith(status: RunSessionStatus.paused);
  }

  void completeFinish() {
    if (state.status != RunSessionStatus.finishing) return;
    final session = state.session;
    if (session == null) return;

    state = state.copyWith(
      status: RunSessionStatus.completed,
      summary: RunSummary(
        completedAt: DateTime.now(),
        metrics: session.metrics,
        achievement: _achievementFor(session.metrics),
      ),
    );
  }

  void reset() {
    _stopTimer();
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

  String _achievementFor(RunMetrics metrics) {
    if (metrics.distanceKm >= 5) return 'Motion Path expanded';
    if (metrics.elapsed.inMinutes >= 20) return 'Consistency builder';
    return 'First movement logged';
  }
}
