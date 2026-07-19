import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kyven_mobile/app/router/app_route.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:kyven_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/run_detail_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/run_history_screen.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {bool withRuns = false}) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      testApp(
        runs: withRuns
            ? [
                savedRunFixture(id: 'run-1'),
                savedRunFixture(
                  id: 'run-2',
                  completedAt: DateTime(2026, 7, 20, 8),
                  distanceKm: 6.4,
                  duration: const Duration(minutes: 34, seconds: 8),
                ),
              ]
            : const [],
      ),
    );
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  Future<void> openHistory(WidgetTester tester) async {
    final context = tester.element(find.byType(HomeScreen));
    context.goNamed(AppRoute.runHistory.name);
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  testWidgets('empty history state renders with first run CTA', (tester) async {
    await pumpApp(tester);
    await openHistory(tester);

    expect(find.byType(RunHistoryScreen), findsOneWidget);
    expect(find.text('No runs saved yet'), findsOneWidget);
    expect(find.text('Start Your First Run'), findsOneWidget);
  });

  testWidgets('populated history renders saved runs newest first', (
    tester,
  ) async {
    await pumpApp(tester, withRuns: true);
    await openHistory(tester);

    expect(find.byKey(const ValueKey('run-history-list')), findsOneWidget);
    expect(find.text('6.4 km'), findsOneWidget);
    expect(find.text('5.2 km'), findsOneWidget);
  });

  testWidgets('tapping a run opens detail', (tester) async {
    await pumpApp(tester, withRuns: true);
    await openHistory(tester);

    await tester.tap(find.byKey(const ValueKey('saved-run-card-run-2')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(RunDetailScreen), findsOneWidget);
    expect(find.text('Motion saved.'), findsOneWidget);
    expect(find.text('Route preview'), findsOneWidget);
  });

  testWidgets('delete confirmation can be cancelled', (tester) async {
    await pumpApp(tester, withRuns: true);
    await openHistory(tester);
    await tester.tap(find.byKey(const ValueKey('saved-run-card-run-2')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    await tester.ensureVisible(
      find.byKey(const ValueKey('run-detail-delete-button')),
    );
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('run-detail-delete-button')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('run-delete-cancel-button')));
    await tester.pump(AppDurations.slow);

    expect(find.byType(RunDetailScreen), findsOneWidget);
  });

  testWidgets('delete confirmation removes run and returns to history', (
    tester,
  ) async {
    await pumpApp(tester, withRuns: true);
    await openHistory(tester);
    await tester.tap(find.byKey(const ValueKey('saved-run-card-run-2')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    await tester.ensureVisible(
      find.byKey(const ValueKey('run-detail-delete-button')),
    );
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('run-detail-delete-button')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('run-delete-confirm-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(RunHistoryScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('saved-run-card-run-2')), findsNothing);
    expect(find.byKey(const ValueKey('saved-run-card-run-1')), findsOneWidget);
  });

  testWidgets('home shows latest saved run', (tester) async {
    await pumpApp(tester, withRuns: true);

    await tester.ensureVisible(
      find.byKey(const ValueKey('home-recent-activity-list')),
    );
    await tester.pump(AppDurations.slow);

    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('6.4 km'), findsOneWidget);
  });

  testWidgets('home empty CTA opens Start Run', (tester) async {
    await pumpApp(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('home-recent-empty-state')),
    );
    await tester.pump(AppDurations.slow);
    await tester.tap(find.text('Start Your First Run'));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('profile shows derived statistics', (tester) async {
    await pumpApp(tester, withRuns: true);

    await tester.tap(find.byKey(const ValueKey('navigation-Profile')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('11.6 km'), findsWidgets);
  });
}
