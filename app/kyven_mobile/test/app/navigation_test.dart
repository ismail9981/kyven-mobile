import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kyven_mobile/app/router/app_route.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/design_system/presentation/screens/design_system_screen.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/start_run_screen.dart';
import 'package:kyven_mobile/features/training/presentation/screens/training_plan_detail_screen.dart';
import 'package:kyven_mobile/features/training/presentation/screens/training_screen.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(testApp());
    await tester.pump();
  }

  testWidgets('bottom navigation switches between destinations', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('navigation-Training')));
    await tester.pump();
    expect(find.byType(TrainingScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('navigation-Home')));
    await tester.pump();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('tab-local training route state is preserved', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('navigation-Training')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.ensureVisible(
      find.byKey(const ValueKey('training-plan-beginner-5k')),
    );
    await tester.pump(AppDurations.fast);
    await tester.tap(find.byKey(const ValueKey('training-plan-beginner-5k')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    expect(find.byType(TrainingPlanDetailScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('navigation-Home')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('navigation-Training')));
    await tester.pump();

    expect(find.byType(TrainingPlanDetailScreen), findsOneWidget);
  });

  testWidgets('Start Run destination opens from bottom navigation', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('navigation-Start Run')));
    await tester.pump();

    expect(find.byType(StartRunScreen), findsOneWidget);
    expect(find.text('GPS PREVIEW'), findsOneWidget);
  });

  testWidgets('development design-system route renders outside the shell', (
    tester,
  ) async {
    await pumpApp(tester);

    final context = tester.element(find.byType(HomeScreen));
    context.goNamed(AppRoute.designSystem.name);
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(DesignSystemScreen), findsOneWidget);
    expect(find.text('Color roles'), findsOneWidget);
    expect(find.byKey(const ValueKey('navigation-Home')), findsNothing);
  });
}
