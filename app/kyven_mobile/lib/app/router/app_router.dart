import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/presentation/routes/activities_route.dart';
import '../../features/authentication/presentation/routes/authentication_route.dart';
import '../../features/challenges/presentation/routes/challenges_route.dart';
import '../../features/design_system/presentation/routes/design_system_route.dart';
import '../../features/home/presentation/routes/home_route.dart';
import '../../features/notifications/presentation/routes/notifications_route.dart';
import '../../features/onboarding/presentation/routes/onboarding_route.dart';
import '../../features/profile/presentation/routes/profile_route.dart';
import '../../features/run_tracking/presentation/routes/start_run_route.dart';
import '../../features/settings/presentation/routes/settings_route.dart';
import '../../features/splash/presentation/routes/splash_route.dart';
import '../../features/training/presentation/routes/training_route.dart';
import '../errors/app_error_screen.dart';
import '../shell/app_shell.dart';
import 'app_route.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoute.home.path,
    routes: [
      SplashRoute.route,
      OnboardingRoute.route,
      AuthenticationRoute.route,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          HomeRoute.branch,
          TrainingRoute.branch,
          StartRunRoute.branch,
          ChallengesRoute.branch,
          ProfileRoute.branch,
        ],
      ),
      ActivitiesRoute.route,
      NotificationsRoute.route,
      SettingsRoute.route,
      if (kDebugMode) DesignSystemRoute.route,
    ],
    errorBuilder: (context, state) => AppErrorScreen(
      message: state.error?.message ?? 'The requested route is unavailable.',
    ),
  );

  ref.onDispose(router.dispose);
  return router;
});
