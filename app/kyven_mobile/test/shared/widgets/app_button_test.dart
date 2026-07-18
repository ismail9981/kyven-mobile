import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/core/theme/app_theme.dart';
import 'package:kyven_mobile/shared/widgets/app_button.dart';

void main() {
  testWidgets('invokes the primary button action', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton(label: 'Continue', onPressed: () => tapCount += 1),
        ),
      ),
    );

    await tester.tap(find.text('Continue'));

    expect(tapCount, 1);
  });

  testWidgets('disables its action while loading', (tester) async {
    var wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton(
            label: 'Continue',
            isLoading: true,
            onPressed: () => wasPressed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppButton));

    expect(wasPressed, isFalse);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
