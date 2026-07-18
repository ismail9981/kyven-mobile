import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kyven_mobile/app/app.dart';
import 'package:kyven_mobile/app/router/app_route.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/features/authentication/presentation/screens/authentication_screen.dart';
import 'package:kyven_mobile/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:kyven_mobile/features/authentication/presentation/screens/guest_confirmation_screen.dart';
import 'package:kyven_mobile/features/authentication/presentation/screens/login_screen.dart';
import 'package:kyven_mobile/features/authentication/presentation/screens/register_screen.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';

void main() {
  void configurePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpAuthHub(WidgetTester tester) async {
    configurePhoneViewport(tester);
    await tester.pumpWidget(const ProviderScope(child: KyvenApp()));
    await tester.pump();

    final context = tester.element(find.byType(HomeScreen));
    context.goNamed(AppRoute.authentication.name);
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  Future<void> pumpRoute(WidgetTester tester, AppRoute route) async {
    configurePhoneViewport(tester);
    await tester.pumpWidget(const ProviderScope(child: KyvenApp()));
    await tester.pump();

    final context = tester.element(find.byType(HomeScreen));
    context.goNamed(route.name);
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  testWidgets('guest mode flow confirms then routes home', (tester) async {
    await pumpAuthHub(tester);

    expect(find.byType(AuthenticationScreen), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('auth-guest-button')));
    await tester.pump(AppDurations.fast);
    await tester.tap(find.byKey(const ValueKey('auth-guest-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(GuestConfirmationScreen), findsOneWidget);
    expect(find.text('Continue without an account?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('guest-continue-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('navigation-Home')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('authentication hub navigates to register', (tester) async {
    await pumpAuthHub(tester);

    await tester.tap(find.byKey(const ValueKey('auth-create-account-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Start with a clean slate.'), findsOneWidget);
  });

  testWidgets('authentication hub navigates to login', (tester) async {
    await pumpAuthHub(tester);

    await tester.tap(find.byKey(const ValueKey('auth-sign-in-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Return to your rhythm.'), findsOneWidget);
  });

  testWidgets('login navigates to forgot password and shows success state', (
    tester,
  ) async {
    await pumpRoute(tester, AppRoute.login);

    await tester.tap(find.byKey(const ValueKey('forgot-password-link')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('forgot-email-field')),
      'runner@kyven.test',
    );
    await tester.tap(find.byKey(const ValueKey('forgot-submit-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(
      find.byKey(const ValueKey('forgot-password-success')),
      findsOneWidget,
    );
    expect(find.text('Check your inbox.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mock sign in succeeds and routes home', (tester) async {
    await pumpRoute(tester, AppRoute.login);

    await tester.enterText(
      find.byKey(const ValueKey('login-email-field')),
      'runner@kyven.test',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password-field')),
      'password',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('login-submit-button')),
    );
    await tester.pump(AppDurations.fast);
    await tester.tap(find.byKey(const ValueKey('login-submit-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('navigation-Home')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct guest route can continue home', (tester) async {
    await pumpRoute(tester, AppRoute.guest);

    expect(find.byType(GuestConfirmationScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('guest-continue-button')));
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
