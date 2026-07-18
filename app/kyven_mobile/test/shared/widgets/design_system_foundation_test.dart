import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/core/theme/app_layout.dart';
import 'package:kyven_mobile/core/theme/app_theme.dart';
import 'package:kyven_mobile/shared/widgets/widgets.dart';

Widget _testApp(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('AppButton renders supported variants and states', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(label: 'Primary', onPressed: () {}),
            AppButton(
              label: 'Secondary',
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
            AppButton(
              label: 'Ghost',
              variant: AppButtonVariant.ghost,
              onPressed: () {},
            ),
            AppButton(
              label: 'Destructive',
              variant: AppButtonVariant.destructive,
              onPressed: () {},
            ),
            const AppButton(label: 'Disabled', onPressed: null),
            AppButton(label: 'Loading', isLoading: true, onPressed: () {}),
          ],
        ),
      ),
    );

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
    expect(find.text('Ghost'), findsOneWidget);
    expect(find.text('Destructive'), findsOneWidget);
    expect(find.text('Disabled'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppButton maintains the minimum touch target', (tester) async {
    await tester.pumpWidget(
      _testApp(AppButton(label: 'Continue', onPressed: () {})),
    );

    final size = tester.getSize(find.byType(AppButton));

    expect(size.height, greaterThanOrEqualTo(AppLayout.minimumTapTarget));
    expect(size.width, greaterThanOrEqualTo(AppLayout.minimumTapTarget));
  });

  testWidgets('AppTextField reports text changes', (tester) async {
    var value = '';

    await tester.pumpWidget(
      _testApp(
        AppTextField(
          label: 'Name',
          hint: 'Runner',
          onChanged: (text) => value = text,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Alex');

    expect(value, 'Alex');
    expect(find.text('Alex'), findsOneWidget);
  });

  testWidgets('AppCard renders standard, elevated, and interactive variants', (
    tester,
  ) async {
    var pressed = false;

    await tester.pumpWidget(
      _testApp(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppCard(child: Text('Standard')),
            const AppCard(
              variant: AppCardVariant.elevated,
              child: Text('Elevated'),
            ),
            AppCard(
              variant: AppCardVariant.interactive,
              onTap: () => pressed = true,
              child: const Text('Interactive'),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Interactive'));

    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Elevated'), findsOneWidget);
    expect(pressed, isTrue);
  });

  testWidgets('loading, empty, and error states render accessibly', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLoadingIndicator(label: 'Loading routes'),
            AppEmptyState(
              title: 'No activities yet',
              message: 'Completed runs will appear here.',
              icon: Icons.route_outlined,
            ),
            AppErrorState(
              title: 'Unable to load',
              message: 'Try again shortly.',
            ),
          ],
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No activities yet'), findsOneWidget);
    expect(find.text('Unable to load'), findsOneWidget);
  });

  testWidgets('critical components tolerate large text scaling', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      _testApp(
        AppResponsiveContent(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: 'Continue with a longer label',
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              const AppTextField(label: 'Email address'),
              const SizedBox(height: 16),
              const AppEmptyState(
                title: 'No movement yet',
                message: 'Your first saved run will appear here.',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
