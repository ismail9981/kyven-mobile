import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kyven_mobile/app/app.dart';
import 'package:kyven_mobile/app/router/app_route.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/activities/presentation/screens/activities_screen.dart';
import 'package:kyven_mobile/features/authentication/presentation/screens/authentication_screen.dart';
import 'package:kyven_mobile/features/challenges/presentation/screens/challenges_screen.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:kyven_mobile/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:kyven_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:kyven_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:kyven_mobile/features/run_tracking/presentation/screens/start_run_screen.dart';
import 'package:kyven_mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:kyven_mobile/features/splash/presentation/screens/splash_screen.dart';
import 'package:kyven_mobile/features/training/presentation/screens/training_screen.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KyvenApp()));
    await tester.pump();
  }

  testWidgets('centralized route names navigate to shell destinations', (
    tester,
  ) async {
    await pumpApp(tester);

    var context = tester.element(find.byType(HomeScreen));
    final shellRoutes = <AppRoute, Type>{
      AppRoute.home: HomeScreen,
      AppRoute.training: TrainingScreen,
      AppRoute.run: StartRunScreen,
      AppRoute.challenges: ChallengesScreen,
      AppRoute.profile: ProfileScreen,
    };

    for (final entry in shellRoutes.entries) {
      context.goNamed(entry.key.name);
      await tester.pump();
      await tester.pump(AppDurations.slow);
      expect(find.byType(entry.value), findsOneWidget);
      if (entry.key == AppRoute.run) {
        expect(find.byKey(const ValueKey('navigation-Home')), findsNothing);
      } else {
        expect(find.byKey(const ValueKey('navigation-Home')), findsOneWidget);
      }
      context = tester.element(find.byType(entry.value));
    }
  });

  testWidgets('centralized route names navigate to top-level routes', (
    tester,
  ) async {
    await pumpApp(tester);

    var context = tester.element(find.byType(HomeScreen));
    final topLevelRoutes = <AppRoute, Type>{
      AppRoute.splash: SplashScreen,
      AppRoute.onboarding: OnboardingScreen,
      AppRoute.authentication: AuthenticationScreen,
      AppRoute.activities: ActivitiesScreen,
      AppRoute.notifications: NotificationsScreen,
      AppRoute.settings: SettingsScreen,
    };

    for (final entry in topLevelRoutes.entries) {
      context.goNamed(entry.key.name);
      await tester.pump();
      await tester.pump(AppDurations.slow);
      expect(find.byType(entry.value), findsOneWidget);
      expect(find.byKey(const ValueKey('navigation-Home')), findsNothing);
      context = tester.element(find.byType(entry.value));
    }
  });
}
