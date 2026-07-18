import 'package:go_router/go_router.dart';

import '../../../../app/router/app_page_transitions.dart';
import '../../../../app/router/app_route.dart';
import '../screens/onboarding_screen.dart';

abstract final class OnboardingRoute {
  static GoRoute get route => GoRoute(
    name: AppRoute.onboarding.name,
    path: AppRoute.onboarding.path,
    pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
      state: state,
      child: const OnboardingScreen(),
    ),
  );
}
