import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kyven_mobile/app/app.dart';
import 'package:kyven_mobile/app/router/app_route.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/design_system/presentation/screens/design_system_screen.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/start_run_screen.dart';
import 'package:kyven_mobile/features/training/presentation/screens/training_screen.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KyvenApp()));
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

  testWidgets('tab-local selection state is preserved', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('navigation-Training')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('10K')));
    await tester.pump();
    expect(find.text('10K foundation'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('navigation-Home')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('navigation-Training')));
    await tester.pump();

    expect(find.text('10K foundation'), findsOneWidget);
  });

  testWidgets('Start Run destination opens from bottom navigation', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('navigation-Start Run')));
    await tester.pump();

    expect(find.byType(StartRunScreen), findsOneWidget);
    expect(find.text('GPS LOCKED · PREVIEW'), findsOneWidget);
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
