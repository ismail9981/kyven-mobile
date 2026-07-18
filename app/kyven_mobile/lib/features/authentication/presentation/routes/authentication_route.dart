import 'package:go_router/go_router.dart';

import '../../../../app/router/app_page_transitions.dart';
import '../../../../app/router/app_route.dart';
import '../screens/authentication_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/guest_confirmation_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

abstract final class AuthenticationRoute {
  static List<GoRoute> get routes => [
    route,
    loginRoute,
    registerRoute,
    forgotPasswordRoute,
    guestRoute,
  ];

  static GoRoute get route => GoRoute(
    name: AppRoute.authentication.name,
    path: AppRoute.authentication.path,
    pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
      state: state,
      child: const AuthenticationScreen(),
    ),
  );

  static GoRoute get loginRoute => GoRoute(
    name: AppRoute.login.name,
    path: AppRoute.login.path,
    pageBuilder: (context, state) =>
        AppPageTransitions.fadeSlide(state: state, child: const LoginScreen()),
  );

  static GoRoute get registerRoute => GoRoute(
    name: AppRoute.register.name,
    path: AppRoute.register.path,
    pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
      state: state,
      child: const RegisterScreen(),
    ),
  );

  static GoRoute get forgotPasswordRoute => GoRoute(
    name: AppRoute.forgotPassword.name,
    path: AppRoute.forgotPassword.path,
    pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
      state: state,
      child: const ForgotPasswordScreen(),
    ),
  );

  static GoRoute get guestRoute => GoRoute(
    name: AppRoute.guest.name,
    path: AppRoute.guest.path,
    pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
      state: state,
      child: const GuestConfirmationScreen(),
    ),
  );
}
