import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/live_run_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/run_summary_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/start_run_screen.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp());
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  Future<void> openPreparationFromHome(WidgetTester tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('home-start-run-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  Future<void> beginLiveRun(WidgetTester tester) async {
    await openPreparationFromHome(tester);
    await tester.tap(find.byKey(const ValueKey('run-begin-session-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  testWidgets('Start Run flow opens preparation from Home', (tester) async {
    await openPreparationFromHome(tester);

    expect(find.byType(StartRunScreen), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('GPS LOCKED · PREVIEW'), findsOneWidget);
    expect(find.byKey(const ValueKey('navigation-Home')), findsNothing);
  });

  testWidgets('preparation shows countdown and begin session action', (
    tester,
  ) async {
    await openPreparationFromHome(tester);

    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsNothing);
    expect(find.text('1'), findsNothing);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsNothing);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('1'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Go'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('run-begin-session-button')),
      findsOneWidget,
    );
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
    expect(find.text('Calories'), findsOneWidget);
  });

  testWidgets('pause and resume update primary control', (tester) async {
    await beginLiveRun(tester);

    expect(find.byKey(const ValueKey('run-pause-button')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('run-pause-button')));
    await tester.pump();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.byKey(const ValueKey('run-resume-button')), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('run-resume-button')));
    await tester.pump();

    expect(find.text('Running'), findsOneWidget);
    expect(find.byKey(const ValueKey('run-pause-button')), findsOneWidget);
  });

  testWidgets('finish confirmation can be cancelled', (tester) async {
    await beginLiveRun(tester);

    await tester.tap(find.byKey(const ValueKey('run-finish-button')));
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

    await tester.tap(find.byKey(const ValueKey('run-finish-button')));
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
  });

  testWidgets('Done resets summary and returns Home', (tester) async {
    await beginLiveRun(tester);
    await tester.pump(const Duration(seconds: 5));

    await tester.tap(find.byKey(const ValueKey('run-finish-button')));
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

    await tester.tap(find.byKey(const ValueKey('run-finish-button')));
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
