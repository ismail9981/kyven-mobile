import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kyven_mobile/app/router/app_route.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/authentication/presentation/screens/authentication_screen.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:kyven_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpOnboarding(WidgetTester tester) async {
    await tester.pumpWidget(testApp());
    await tester.pump();

    final context = tester.element(find.byType(HomeScreen));
    context.goNamed(AppRoute.onboarding.name);
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  Future<void> tapPrimary(WidgetTester tester, String label) async {
    await tester.tap(find.byKey(ValueKey('onboarding-primary-$label')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  testWidgets('onboarding flow advances to authentication on completion', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Build your movement identity.'), findsOneWidget);

    await tapPrimary(tester, 'Get Started');
    expect(find.text('Consistency becomes visible.'), findsOneWidget);

    await tapPrimary(tester, 'Continue');
    expect(find.text('Choose what moves you.'), findsOneWidget);

    await tapPrimary(tester, 'Continue');
    expect(find.text('Meet KYVEN where you are.'), findsOneWidget);

    await tapPrimary(tester, 'Continue');
    expect(find.text('You stay in control.'), findsOneWidget);

    await tapPrimary(tester, 'Continue');
    expect(find.text('Your journey starts now.'), findsOneWidget);

    await tapPrimary(tester, 'Continue');
    expect(find.byType(AuthenticationScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('page navigation keeps selectable onboarding UI state', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    await tapPrimary(tester, 'Get Started');
    await tapPrimary(tester, 'Continue');

    await tester.tap(find.byKey(const ValueKey('onboarding-goal-run-faster')));
    await tester.pump(AppDurations.fast);
    await tester.ensureVisible(
      find.byKey(const ValueKey('onboarding-goal-first-5k')),
    );
    await tester.pump(AppDurations.fast);
    await tester.tap(find.byKey(const ValueKey('onboarding-goal-first-5k')));
    await tester.pump(AppDurations.fast);

    expect(
      find.byKey(const ValueKey('onboarding-goal-run-faster-selected')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('onboarding-goal-first-5k-selected')),
      findsOneWidget,
    );

    await tapPrimary(tester, 'Continue');
    await tester.tap(
      find.byKey(const ValueKey('onboarding-activity-beginner')),
    );
    await tester.pump(AppDurations.fast);

    expect(
      find.byKey(const ValueKey('onboarding-activity-beginner-selected')),
      findsOneWidget,
    );
    expect(find.text('Meet KYVEN where you are.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skip navigates from onboarding to authentication route', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    await tester.tap(find.byKey(const ValueKey('onboarding-secondary-skip')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(AuthenticationScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
