import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_theme_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? AppPalette.ink : AppPalette.frost;
    final foreground = isDark ? AppPalette.white : AppPalette.ink;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppPalette.electric,
          brightness: brightness,
          surface: surface,
        ).copyWith(
          primary: AppPalette.electric,
          onPrimary: AppPalette.white,
          primaryContainer: isDark
              ? AppPalette.electricDeep
              : AppPalette.electricSoft,
          onPrimaryContainer: isDark
              ? AppPalette.white
              : AppPalette.electricDeep,
          secondary: isDark ? AppPalette.lime : AppPalette.limeDeep,
          onSecondary: AppPalette.ink,
          tertiary: isDark ? AppPalette.violet : AppPalette.violetDeep,
          error: isDark ? AppPalette.danger : AppPalette.dangerDeep,
          surface: surface,
          onSurface: foreground,
          outline: isDark ? AppPalette.steel : AppPalette.cloud,
          outlineVariant: isDark ? AppPalette.graphite : AppPalette.cloud,
        );
    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
    );
    final textTheme = AppTypography.textTheme(base.textTheme, foreground);
    final appColors = isDark ? AppThemeColors.dark() : AppThemeColors.light();

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: surface,
      canvasColor: surface,
      extensions: [appColors],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        foregroundColor: foreground,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: AppPalette.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.control,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.control,
          borderSide: BorderSide(color: appColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.control,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.control,
          borderSide: BorderSide(color: appColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.control,
          borderSide: BorderSide(color: appColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.control,
          borderSide: BorderSide(color: appColors.divider),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: appColors.disabledText,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: appColors.secondaryText,
        ),
        helperStyle: textTheme.bodySmall?.copyWith(
          color: appColors.secondaryText,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: appColors.error),
      ),
      dividerTheme: DividerThemeData(color: appColors.divider),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: appColors.accent,
        linearTrackColor: appColors.divider,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: appColors.elevatedSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: appColors.elevatedSurface,
        modalBackgroundColor: appColors.elevatedSurface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheet),
      ),
    );
  }
}
