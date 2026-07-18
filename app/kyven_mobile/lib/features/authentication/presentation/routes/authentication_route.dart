import 'package:go_router/go_router.dart';

import '../../../../app/router/app_page_transitions.dart';
import '../../../../app/router/app_route.dart';
import '../screens/authentication_screen.dart';

abstract final class AuthenticationRoute {
  static GoRoute get route => GoRoute(
    name: AppRoute.authentication.name,
    path: AppRoute.authentication.path,
    pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
      state: state,
      child: const AuthenticationScreen(),
    ),
  );
}
