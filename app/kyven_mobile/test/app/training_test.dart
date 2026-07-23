import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/training/presentation/screens/training_plan_detail_screen.dart';
import 'package:kyven_mobile/features/training/presentation/screens/training_screen.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpTraining(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp());
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('navigation-Training')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  testWidgets('training screen displays available plans', (tester) async {
    await pumpTraining(tester);

    expect(find.byType(TrainingScreen), findsOneWidget);
    expect(find.text('Available Plans'), findsOneWidget);
    expect(find.text('Beginner 5K'), findsOneWidget);
    expect(find.text('Improve Pace'), findsOneWidget);
    expect(find.text('10K Preparation'), findsOneWidget);
  });

  testWidgets('plan detail displays weeks, days, and progress', (tester) async {
    await pumpTraining(tester);

    await tester.tap(find.byKey(const ValueKey('training-plan-beginner-5k')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(TrainingPlanDetailScreen), findsOneWidget);
    expect(
      find.byKey(const ValueKey('training-progress-card')),
      findsOneWidget,
    );
    expect(find.text('Completed Sessions'), findsOneWidget);
    expect(find.text('Current Week'), findsOneWidget);
    expect(find.byKey(const ValueKey('training-week-1')), findsOneWidget);
    expect(find.text('Day 1 · Easy Run'), findsWidgets);
  });

  testWidgets('marking today complete updates progress', (tester) async {
    await pumpTraining(tester);

    await tester.tap(find.byKey(const ValueKey('training-plan-beginner-5k')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.text('0%'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('training-complete-session-button')),
    );
    await tester.tap(
      find.byKey(const ValueKey('training-complete-session-button')),
    );
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.text('4%'), findsOneWidget);
    expect(find.text('Session Complete'), findsNothing);
    expect(find.text('Day 2 · Recovery'), findsWidgets);
  });
}
