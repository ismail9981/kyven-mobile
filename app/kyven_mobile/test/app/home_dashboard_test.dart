import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/start_run_screen.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpDashboard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp());
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump(AppDurations.slow);
  }

  testWidgets('home dashboard renders the MVP structure', (tester) async {
    await pumpDashboard(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Good Morning,'), findsOneWidget);
    expect(find.text('Morning, Alex.'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-start-run-card')), findsOneWidget);
    expect(find.text('Today’s Activity'), findsOneWidget);
  });

  testWidgets('start run button opens the start run destination', (
    tester,
  ) async {
    await pumpDashboard(tester);

    await tester.tap(find.byKey(const ValueKey('home-start-run-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(StartRunScreen), findsOneWidget);
  });

  testWidgets('weekly progress visualization renders', (tester) async {
    await pumpDashboard(tester);

    await reveal(tester, find.byKey(const ValueKey('home-weekly-progress')));

    expect(find.text('Weekly Progress'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-weekly-progress')), findsOneWidget);
  });

  testWidgets('training plan preview renders', (tester) async {
    await pumpDashboard(tester);

    await reveal(tester, find.byKey(const ValueKey('home-training-card')));

    expect(find.byKey(const ValueKey('home-training-card')), findsOneWidget);
    expect(find.text('Easy Run'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-view-plan-button')), findsOneWidget);
  });

  testWidgets('challenges preview renders', (tester) async {
    await pumpDashboard(tester);

    await reveal(
      tester,
      find.byKey(const ValueKey('home-challenges-carousel')),
    );

    expect(
      find.byKey(const ValueKey('home-challenges-carousel')),
      findsOneWidget,
    );
    expect(find.text('Run 20 km this week'), findsOneWidget);
  });

  testWidgets('recent activity renders empty state before first saved run', (
    tester,
  ) async {
    await pumpDashboard(tester);

    await reveal(tester, find.byKey(const ValueKey('home-recent-empty-state')));

    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('No runs saved yet'), findsOneWidget);
    expect(find.text('Start Your First Run'), findsOneWidget);
  });
}
