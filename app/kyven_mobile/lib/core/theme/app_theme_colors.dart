import 'package:flutter/material.dart';

import 'app_palette.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.elevatedSurface,
    required this.primaryText,
    required this.secondaryText,
    required this.disabledText,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.outline,
    required this.divider,
    required this.overlay,
    required this.highlight,
  });

  factory AppThemeColors.light() => const AppThemeColors(
    background: AppPalette.frost,
    surface: AppPalette.white,
    elevatedSurface: AppPalette.white,
    primaryText: AppPalette.ink,
    secondaryText: AppPalette.smoke,
    disabledText: AppPalette.smokeLight,
    accent: AppPalette.limeDeep,
    success: AppPalette.successDeep,
    warning: AppPalette.warningDeep,
    info: AppPalette.infoDeep,
    error: AppPalette.dangerDeep,
    outline: AppPalette.cloud,
    divider: AppPalette.cloud,
    overlay: AppPalette.glassLight,
    highlight: AppPalette.violetDeep,
  );

  factory AppThemeColors.dark() => const AppThemeColors(
    background: AppPalette.ink,
    surface: AppPalette.graphite,
    elevatedSurface: AppPalette.steel,
    primaryText: AppPalette.white,
    secondaryText: AppPalette.smoke,
    disabledText: AppPalette.smokeDark,
    accent: AppPalette.lime,
    success: AppPalette.success,
    warning: AppPalette.warning,
    info: AppPalette.info,
    error: AppPalette.danger,
    outline: AppPalette.steel,
    divider: AppPalette.steel,
    overlay: AppPalette.glassDark,
    highlight: AppPalette.violet,
  );

  final Color accent;
  final Color background;
  final Color disabledText;
  final Color divider;
  final Color elevatedSurface;
  final Color error;
  final Color highlight;
  final Color info;
  final Color outline;
  final Color overlay;
  final Color primaryText;
  final Color secondaryText;
  final Color surface;
  final Color success;
  final Color warning;

  Color get danger => error;
  Color get glassBorder => overlay;
  Color get raisedSurface => elevatedSurface;
  Color get subtleSurface => surface;

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? elevatedSurface,
    Color? primaryText,
    Color? secondaryText,
    Color? disabledText,
    Color? accent,
    Color? success,
    Color? warning,
    Color? info,
    Color? error,
    Color? outline,
    Color? divider,
    Color? overlay,
    Color? highlight,
  }) => AppThemeColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    elevatedSurface: elevatedSurface ?? this.elevatedSurface,
    primaryText: primaryText ?? this.primaryText,
    secondaryText: secondaryText ?? this.secondaryText,
    disabledText: disabledText ?? this.disabledText,
    accent: accent ?? this.accent,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    info: info ?? this.info,
    error: error ?? this.error,
    outline: outline ?? this.outline,
    divider: divider ?? this.divider,
    overlay: overlay ?? this.overlay,
    highlight: highlight ?? this.highlight,
  );

  @override
  AppThemeColors lerp(covariant AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      elevatedSurface:
          Color.lerp(elevatedSurface, other.elevatedSurface, t) ??
          elevatedSurface,
      primaryText: Color.lerp(primaryText, other.primaryText, t) ?? primaryText,
      secondaryText:
          Color.lerp(secondaryText, other.secondaryText, t) ?? secondaryText,
      disabledText:
          Color.lerp(disabledText, other.disabledText, t) ?? disabledText,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      error: Color.lerp(error, other.error, t) ?? error,
      outline: Color.lerp(outline, other.outline, t) ?? outline,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      overlay: Color.lerp(overlay, other.overlay, t) ?? overlay,
      highlight: Color.lerp(highlight, other.highlight, t) ?? highlight,
    );
  }
}

extension AppThemeColorsContext on BuildContext {
  AppThemeColors get appColors => Theme.of(this).extension<AppThemeColors>()!;
}
