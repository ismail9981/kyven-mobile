import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kyven_mobile/app/router/app_route.dart';
import 'package:kyven_mobile/features/home/presentation/screens/home_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('application launches into the home destination', (tester) async {
    await tester.pumpWidget(testApp());
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Runner'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(HomeScreen))).useMaterial3,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact layout supports enlarged text without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(testApp());
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    for (final destination in [
      'Training',
      'Start Run',
      'Challenges',
      'Profile',
    ]) {
      await tester.tap(find.byKey(ValueKey('navigation-$destination')));
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: '$destination should support compact enlarged-text layouts',
      );
      if (destination == 'Start Run') {
        final context = tester.element(
          find.byType(HomeScreen, skipOffstage: false),
        );
        context.goNamed(AppRoute.home.name);
        await tester.pump();
      }
    }
  });
}
