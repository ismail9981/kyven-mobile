import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/location_permission_status.dart';
import 'package:kyven_mobile/features/run_tracking/domain/entities/location_point.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/live_run_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/run_summary_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/start_run_screen.dart';

import '../fakes/fake_location_tracking_repository.dart';
import '../fakes/fake_run_history_repository.dart';
import '../helpers/test_app.dart';

void main() {
  LocationPoint gpsPoint({
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

  Future<({FakeRunHistoryRepository runs, FakeLocationTrackingRepository gps})>
  pumpApp(WidgetTester tester, {FakeLocationTrackingRepository? gps}) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeRunHistoryRepository();
    final locationRepository = gps ?? FakeLocationTrackingRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      testApp(repository: repository, locationRepository: locationRepository),
    );
    await tester.pump();
    await tester.pump(AppDurations.slow);
    return (runs: repository, gps: locationRepository);
  }

  Future<({FakeRunHistoryRepository runs, FakeLocationTrackingRepository gps})>
  openPreparationFromHome(
    WidgetTester tester, {
    FakeLocationTrackingRepository? gps,
  }) async {
    final repositories = await pumpApp(tester, gps: gps);
    await tester.tap(find.byKey(const ValueKey('home-start-run-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    return repositories;
  }

  Future<void> beginLiveRun(WidgetTester tester) async {
    await openPreparationFromHome(tester);
    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(AppDurations.slow);
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump(AppDurations.fast);
    await tester.tap(finder);
  }

  testWidgets('Start Run flow opens preparation from Home', (tester) async {
    await openPreparationFromHome(tester);

    expect(find.byType(StartRunScreen), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('GPS PREVIEW'), findsOneWidget);
    expect(find.byKey(const ValueKey('navigation-Home')), findsNothing);
  });

  testWidgets('preparation starts countdown with visible cancel action', (
    tester,
  ) async {
    await openPreparationFromHome(tester);

    expect(find.text('Ready'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('run-begin-session-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('run-countdown-cancel-button')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsNothing);
    expect(find.text('1'), findsNothing);
    expect(
      find.byKey(const ValueKey('run-countdown-cancel-button')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsNothing);
    expect(
      find.byKey(const ValueKey('run-countdown-cancel-button')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('1'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('run-countdown-cancel-button')),
      findsOneWidget,
    );
  });

  testWidgets('cancel returns to preparation and prevents active run', (
    tester,
  ) async {
    final repositories = await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('home-start-run-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.byKey(const ValueKey('run-countdown-cancel-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(StartRunScreen), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('run-begin-session-button')),
      findsOneWidget,
    );
    expect(find.byType(LiveRunScreen), findsNothing);
    expect(await repositories.runs.getAllRuns(), isEmpty);
    expect(repositories.gps.totalSubscriptionCount, 0);
  });

  testWidgets('countdown begins only after location readiness', (tester) async {
    final gps = FakeLocationTrackingRepository();
    await openPreparationFromHome(tester, gps: gps);

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();

    expect(gps.requestPermissionCount, 0);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('permission denied keeps user on preparation', (tester) async {
    final gps = FakeLocationTrackingRepository(
      permissionStatus: LocationPermissionStatus.denied,
      requestedPermissionStatus: LocationPermissionStatus.denied,
    );
    await pumpApp(tester, gps: gps);
    await tester.tap(find.byKey(const ValueKey('home-start-run-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(AppDurations.fast);

    expect(find.byType(StartRunScreen), findsOneWidget);
    expect(find.text('3'), findsNothing);
    expect(find.text('GPS check'), findsOneWidget);
    expect(
      find.textContaining('KYVEN needs location while you run'),
      findsOneWidget,
    );
    expect(gps.requestPermissionCount, 1);
    expect(gps.totalSubscriptionCount, 0);
  });

  testWidgets('permanently denied location exposes app settings action', (
    tester,
  ) async {
    final gps = FakeLocationTrackingRepository(
      permissionStatus: LocationPermissionStatus.deniedForever,
    );
    await pumpApp(tester, gps: gps);
    await tester.tap(find.byKey(const ValueKey('home-start-run-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(AppDurations.fast);

    expect(find.text('Open App Settings'), findsOneWidget);
    await tester.tap(find.text('Open App Settings'));
    await tester.pump();

    expect(gps.appSettingsOpened, isTrue);
  });

  testWidgets('location services disabled exposes location settings action', (
    tester,
  ) async {
    final gps = FakeLocationTrackingRepository(serviceEnabled: false);
    await pumpApp(tester, gps: gps);
    await tester.tap(find.byKey(const ValueKey('home-start-run-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(AppDurations.fast);

    expect(find.text('Open Location Settings'), findsOneWidget);
    await tester.tap(find.text('Open Location Settings'));
    await tester.pump();

    expect(gps.locationSettingsOpened, isTrue);
  });

  testWidgets('back navigation safely cancels countdown', (tester) async {
    await openPreparationFromHome(tester);

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(StartRunScreen), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byType(LiveRunScreen), findsNothing);
  });

  testWidgets('timer cannot start run after late cancellation', (tester) async {
    await openPreparationFromHome(tester);

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('run-countdown-cancel-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(StartRunScreen), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byType(LiveRunScreen), findsNothing);
  });

  testWidgets('rapid repeated cancel taps do not duplicate transitions', (
    tester,
  ) async {
    await openPreparationFromHome(tester);

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    final cancel = find.byKey(const ValueKey('run-countdown-cancel-button'));
    await tester.tap(cancel);
    await tester.tap(cancel);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(StartRunScreen), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byType(LiveRunScreen), findsNothing);
  });

  testWidgets('starting again after cancellation works normally', (
    tester,
  ) async {
    await openPreparationFromHome(tester);

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('run-countdown-cancel-button')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(AppDurations.slow);

    expect(find.byType(LiveRunScreen), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('GPS SEARCHING'), findsOneWidget);
  });

  testWidgets('active run starts one location subscription', (tester) async {
    final repositories = await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('home-start-run-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(AppDurations.slow);

    expect(find.byType(LiveRunScreen), findsOneWidget);
    expect(repositories.gps.totalSubscriptionCount, 1);
    expect(repositories.gps.activeSubscriptionCount, 1);
  });

  testWidgets('normal countdown completion starts exactly one active run', (
    tester,
  ) async {
    await openPreparationFromHome(tester);

    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(AppDurations.slow);
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(LiveRunScreen), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.byKey(const ValueKey('run-pause-button')), findsOneWidget);
  });

  testWidgets('begin session renders live metrics', (tester) async {
    await beginLiveRun(tester);
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(LiveRunScreen), findsOneWidget);
    expect(find.text('RUN//LIVE'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.byKey(const ValueKey('navigation-Home')), findsNothing);
    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
    expect(find.text('Speed km/h'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
  });

  testWidgets('pause and resume update primary control', (tester) async {
    await beginLiveRun(tester);

    expect(find.byKey(const ValueKey('run-pause-button')), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('run-pause-button')));
    await tester.pump();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.byKey(const ValueKey('run-resume-button')), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('run-resume-button')));
    await tester.pump();

    expect(find.text('Running'), findsOneWidget);
    expect(find.byKey(const ValueKey('run-pause-button')), findsOneWidget);
  });

  testWidgets('finish confirmation can be cancelled', (tester) async {
    await beginLiveRun(tester);

    await tapVisible(tester, find.byKey(const ValueKey('run-finish-button')));
    await tester.pump();

    expect(find.text('Finish run?'), findsOneWidget);
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('run-finish-cancel-button')));
    await tester.pump(AppDurations.slow);
    await tester.pump(AppDurations.slow);

    expect(find.byType(LiveRunScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('run-resume-button')), findsOneWidget);
  });

  testWidgets('finish confirmation completes and opens summary', (
    tester,
  ) async {
    await beginLiveRun(tester);
    await tester.pump(const Duration(seconds: 5));

    await tapVisible(tester, find.byKey(const ValueKey('run-finish-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('run-finish-confirm-button')));
    await tester.pump(AppDurations.slow);
    await tester.pump(AppDurations.slow);

    expect(find.byType(RunSummaryScreen), findsOneWidget);
    expect(find.text('Great run.'), findsOneWidget);
    expect(find.text('Share Run'), findsOneWidget);
    expect(find.byKey(const ValueKey('navigation-Home')), findsNothing);
    expect(
      find.byKey(const ValueKey('run-summary-metrics-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('run-summary-ai-coach-card')),
      findsOneWidget,
    );
    expect(find.text('AI COACH'), findsOneWidget);
  });

  testWidgets('finish persists GPS-derived metrics exactly once', (
    tester,
  ) async {
    final repositories = await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('home-start-run-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(AppDurations.slow);

    repositories.gps.emit(
      gpsPoint(latitude: 25.2048, longitude: 55.2708, seconds: 0),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    repositories.gps.emit(
      gpsPoint(latitude: 25.20498, longitude: 55.2708, seconds: 10),
    );
    await tester.pump();

    await tapVisible(tester, find.byKey(const ValueKey('run-finish-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('run-finish-confirm-button')));
    await tester.pump(AppDurations.slow);
    await tester.pump(AppDurations.slow);

    final runs = await repositories.runs.getAllRuns();
    expect(runs, hasLength(1));
    expect(runs.single.distanceKm, closeTo(0.02, 0.004));
    expect(runs.single.averagePace, isNot(Duration.zero));
    expect(runs.single.routePreview, isEmpty);
    expect(runs.single.route.segments, hasLength(1));
    expect(runs.single.route.segments.single.points, hasLength(2));
  });

  testWidgets('Done resets summary and returns Home', (tester) async {
    await beginLiveRun(tester);
    await tester.pump(const Duration(seconds: 5));

    await tapVisible(tester, find.byKey(const ValueKey('run-finish-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('run-finish-confirm-button')));
    await tester.pump(AppDurations.slow);
    await tester.pump(AppDurations.slow);

    await tester.ensureVisible(
      find.byKey(const ValueKey('run-summary-done-button')),
    );
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('run-summary-done-button')));
    await tester.pump(AppDurations.slow);
    await tester.pump(AppDurations.slow);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('navigation-Home')), findsOneWidget);
  });

  testWidgets('run experience copy does not expose implementation words', (
    tester,
  ) async {
    await beginLiveRun(tester);
    await tester.pump(const Duration(seconds: 3));

    expect(
      find.textContaining('placeholder', findRichText: true),
      findsNothing,
    );
    expect(find.textContaining('mock', findRichText: true), findsNothing);

    await tapVisible(tester, find.byKey(const ValueKey('run-finish-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('run-finish-confirm-button')));
    await tester.pump(AppDurations.slow);
    await tester.pump(AppDurations.slow);

    expect(
      find.textContaining('placeholder', findRichText: true),
      findsNothing,
    );
    expect(find.textContaining('mock', findRichText: true), findsNothing);
  });
}
