import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/features/run_tracking/application/run_session_providers.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/location_point.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/run_session.dart';

void main() {
  LocationPoint point({
    required double latitude,
    required double longitude,
    required int seconds,
  }) {
    return LocationPoint(
      latitude: latitude,
      longitude: longitude,
      accuracy: 8,
      recordedAt: DateTime(2026, 7, 21, 7, 0, seconds),
    );
  }

  ProviderContainer createContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('initial state is idle', () {
    final container = createContainer();

    final state = container.read(runSessionProvider);

    expect(state.status, RunSessionStatus.idle);
    expect(state.session, isNull);
    expect(state.summary, isNull);
  });

  test('start transition enters running through preparation', () {
    final container = createContainer();
    final notifier = container.read(runSessionProvider.notifier);

    notifier.prepare();
    expect(
      container.read(runSessionProvider).status,
      RunSessionStatus.preparing,
    );

    notifier.start();
    expect(container.read(runSessionProvider).status, RunSessionStatus.running);
    expect(container.read(runSessionProvider).session, isNotNull);
  });

  test('running timer advances elapsed and moving time', () {
    final container = createContainer();
    final notifier = container.read(runSessionProvider.notifier)..start();

    notifier.tick(const Duration(seconds: 10));
    final metrics = container.read(runSessionProvider).metrics;

    expect(metrics.elapsed, const Duration(seconds: 10));
    expect(metrics.movingTime, const Duration(seconds: 10));
    expect(metrics.distanceKm, 0);
    expect(metrics.calories, greaterThanOrEqualTo(0));
    expect(metrics.heartRate, inInclusiveRange(136, 148));
    expect(metrics.cadence, inInclusiveRange(166, 172));
  });

  test('GPS samples update distance, speed, and pace', () {
    final container = createContainer();
    final notifier = container.read(runSessionProvider.notifier)..start();

    notifier.processLocationPoint(
      point(latitude: 25.2048, longitude: 55.2708, seconds: 0),
    );
    notifier.tick(const Duration(seconds: 10));
    notifier.processLocationPoint(
      point(latitude: 25.20498, longitude: 55.2708, seconds: 10),
    );

    final metrics = container.read(runSessionProvider).metrics;
    expect(metrics.distanceKm, closeTo(0.02, 0.003));
    expect(metrics.currentSpeedMetersPerSecond, closeTo(2, 0.25));
    expect(metrics.currentPace, isNot(Duration.zero));
    expect(metrics.averagePace, isNot(Duration.zero));
  });

  test('pause stops simulated metrics', () {
    final container = createContainer();
    final notifier = container.read(runSessionProvider.notifier)..start();

    notifier.tick(const Duration(seconds: 8));
    notifier.pause();
    final pausedMetrics = container.read(runSessionProvider).metrics;

    notifier.tick(const Duration(seconds: 20));

    expect(container.read(runSessionProvider).status, RunSessionStatus.paused);
    expect(container.read(runSessionProvider).metrics, pausedMetrics);
  });

  test('resume keeps timer safe after pause', () {
    final container = createContainer();
    final notifier = container.read(runSessionProvider.notifier)..start();

    notifier.tick(const Duration(seconds: 8));
    notifier.pause();
    final pausedMetrics = container.read(runSessionProvider).metrics;

    notifier.resume();
    notifier.tick(const Duration(seconds: 8));

    expect(container.read(runSessionProvider).status, RunSessionStatus.running);
    expect(
      container.read(runSessionProvider).metrics.elapsed,
      greaterThan(pausedMetrics.elapsed),
    );
  });

  test('pause ignores GPS points and resume resets baseline', () {
    final container = createContainer();
    final notifier = container.read(runSessionProvider.notifier)..start();

    notifier.processLocationPoint(
      point(latitude: 25.2048, longitude: 55.2708, seconds: 0),
    );
    notifier.tick(const Duration(seconds: 10));
    notifier.processLocationPoint(
      point(latitude: 25.20498, longitude: 55.2708, seconds: 10),
    );
    final beforePause = container.read(runSessionProvider).metrics.distanceKm;

    notifier.pause();
    notifier.processLocationPoint(
      point(latitude: 25.21, longitude: 55.2708, seconds: 20),
    );
    expect(container.read(runSessionProvider).metrics.distanceKm, beforePause);

    notifier.resume();
    notifier.processLocationPoint(
      point(latitude: 25.21, longitude: 55.2708, seconds: 30),
    );
    expect(container.read(runSessionProvider).metrics.distanceKm, beforePause);
  });

  test('finish creates a completed summary', () {
    final container = createContainer();
    final notifier = container.read(runSessionProvider.notifier)..start();

    notifier.tick(const Duration(seconds: 30));
    notifier.requestFinish();
    expect(
      container.read(runSessionProvider).status,
      RunSessionStatus.finishing,
    );

    notifier.completeFinish();
    final state = container.read(runSessionProvider);

    expect(state.status, RunSessionStatus.completed);
    expect(state.summary, isNotNull);
    expect(state.summary?.metrics.elapsed, const Duration(seconds: 30));
  });

  test('reset clears active session and summary', () {
    final container = createContainer();
    final notifier = container.read(runSessionProvider.notifier)..start();

    notifier.tick(const Duration(seconds: 12));
    notifier.requestFinish();
    notifier.completeFinish();
    notifier.reset();

    final state = container.read(runSessionProvider);
    expect(state.status, RunSessionStatus.idle);
    expect(state.session, isNull);
    expect(state.summary, isNull);
  });

  test('invalid transitions are safe no-ops', () {
    final container = createContainer();
    final notifier = container.read(runSessionProvider.notifier);

    notifier.pause();
    notifier.resume();
    notifier.requestFinish();
    notifier.completeFinish();

    final idleState = container.read(runSessionProvider);
    expect(idleState.status, RunSessionStatus.idle);
    expect(idleState.summary, isNull);

    notifier.start();
    notifier.start();
    expect(container.read(runSessionProvider).status, RunSessionStatus.running);
  });
}
