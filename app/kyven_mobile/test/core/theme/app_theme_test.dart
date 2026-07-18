import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/core/theme/app_theme.dart';
import 'package:kyven_mobile/core/theme/app_theme_colors.dart';

void main() {
  testWidgets('light and dark Material 3 themes render without exceptions', (
    tester,
  ) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: Center(child: Text('Theme preview'))),
        ),
      );
      await tester.pump();

      expect(
        Theme.of(tester.element(find.text('Theme preview'))).useMaterial3,
        isTrue,
      );
      final colors = theme.extension<AppThemeColors>();
      expect(colors, isNotNull);
      expect(colors!.background, isA<Color>());
      expect(colors.surface, isA<Color>());
      expect(colors.elevatedSurface, isA<Color>());
      expect(colors.primaryText, isA<Color>());
      expect(colors.secondaryText, isA<Color>());
      expect(colors.disabledText, isA<Color>());
      expect(colors.outline, isA<Color>());
      expect(colors.divider, isA<Color>());
      expect(colors.overlay, isA<Color>());
      expect(tester.takeException(), isNull);
    }
  });
}
