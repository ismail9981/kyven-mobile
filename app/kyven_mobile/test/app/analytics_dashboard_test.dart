import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kyven_mobile/app/router/app_route.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/activities/presentation/screens/activities_screen.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';

import '../fakes/fake_run_history_repository.dart';
import '../helpers/test_app.dart';

void main() {
  final now = DateTime(2026, 7, 22, 12);

  Future<void> openAnalytics(
    WidgetTester tester, {
    FakeRunHistoryRepository? repository,
  }) async {
    await tester.pumpWidget(testApp(repository: repository, analyticsNow: now));
    await tester.pump();
    tester.element(find.byType(HomeScreen)).goNamed(AppRoute.activities.name);
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  testWidgets('analytics dashboard renders empty state', (tester) async {
    await openAnalytics(tester);

    expect(find.byType(ActivitiesScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('analytics-empty-state')), findsOneWidget);
    expect(find.text('No analytics yet'), findsOneWidget);
  });

  testWidgets('analytics dashboard renders calculated sections', (
    tester,
  ) async {
    await openAnalytics(
      tester,
      repository: FakeRunHistoryRepository([
        savedRunFixture(
          completedAt: DateTime(2026, 7, 21),
          distanceKm: 8,
          duration: const Duration(minutes: 44),
        ),
        savedRunFixture(
          id: 'previous',
          completedAt: DateTime(2026, 7, 14),
          distanceKm: 4,
          duration: const Duration(minutes: 24),
        ),
      ]),
    );

    expect(
      find.byKey(const ValueKey('analytics-summary-card')),
      findsOneWidget,
    );
    expect(find.text('8.0 km'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Weekly Distance'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(AppDurations.slow);

    expect(
      find.byKey(const ValueKey('analytics-distance-chart')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Pace Trend'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(AppDurations.slow);

    expect(find.byKey(const ValueKey('analytics-pace-chart')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('analytics-training-load-card')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Personal Records'),
      420,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(AppDurations.slow);

    expect(find.text('Personal Records'), findsOneWidget);
  });

  testWidgets('month selector switches the selected period', (tester) async {
    await openAnalytics(
      tester,
      repository: FakeRunHistoryRepository([
        savedRunFixture(completedAt: DateTime(2026, 7, 21), distanceKm: 8),
        savedRunFixture(
          id: 'month-run',
          completedAt: DateTime(2026, 7, 2),
          distanceKm: 3,
        ),
      ]),
    );

    await tester.tap(find.text('Month'));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.text('Current Month'), findsOneWidget);
    expect(find.text('11.0 km'), findsWidgets);
  });

  testWidgets('analytics reacts when run history repository emits updates', (
    tester,
  ) async {
    final repository = FakeRunHistoryRepository();
    await openAnalytics(tester, repository: repository);

    expect(find.byKey(const ValueKey('analytics-empty-state')), findsOneWidget);

    await repository.saveRun(
      savedRunFixture(completedAt: DateTime(2026, 7, 21), distanceKm: 5),
    );
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byKey(const ValueKey('analytics-dashboard')), findsOneWidget);
    expect(find.text('5.0 km'), findsWidgets);

    await repository.deleteRun('run-1');
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byKey(const ValueKey('analytics-empty-state')), findsOneWidget);
  });
}
