import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppShadows {
  static List<BoxShadow> low(Brightness brightness) => [
    BoxShadow(
      color: AppPalette.black.withValues(
        alpha: brightness == Brightness.light ? 0.08 : 0.28,
      ),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> high(Brightness brightness) => [
    BoxShadow(
      color: AppPalette.black.withValues(
        alpha: brightness == Brightness.light ? 0.14 : 0.46,
      ),
      blurRadius: 34,
      offset: const Offset(0, 18),
    ),
    BoxShadow(
      color: AppPalette.electric.withValues(
        alpha: brightness == Brightness.light ? 0.06 : 0.12,
      ),
      blurRadius: 42,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> glow(Color color, {double opacity = 0.28}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 32,
      spreadRadius: -6,
    ),
  ];
}
