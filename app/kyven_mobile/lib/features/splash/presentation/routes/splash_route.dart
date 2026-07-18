import 'package:go_router/go_router.dart';

import '../../../../app/router/app_page_transitions.dart';
import '../../../../app/router/app_route.dart';
import '../screens/splash_screen.dart';

abstract final class SplashRoute {
  static GoRoute get route => GoRoute(
    name: AppRoute.splash.name,
    path: AppRoute.splash.path,
    pageBuilder: (context, state) =>
        AppPageTransitions.fadeSlide(state: state, child: const SplashScreen()),
  );
}
