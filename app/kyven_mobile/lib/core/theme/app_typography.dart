import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextTheme textTheme(TextTheme base, Color foreground) {
    final body = GoogleFonts.interTextTheme(
      base,
    ).apply(bodyColor: foreground, displayColor: foreground);
    return body.copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        textStyle: body.displayLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        textStyle: body.displayMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        textStyle: body.headlineLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        textStyle: body.headlineMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        textStyle: body.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        textStyle: body.titleLarge,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

extension AppTextThemeRoles on TextTheme {
  TextStyle? get appDisplay => displayLarge;
  TextStyle? get appScreenTitle => headlineLarge;
  TextStyle? get appSectionTitle => titleLarge;
  TextStyle? get appBody => bodyLarge;
  TextStyle? get appBodySecondary => bodyMedium;
  TextStyle? get appMetricLarge => displayMedium;
  TextStyle? get appMetricMedium => headlineMedium;
  TextStyle? get appLabel => labelLarge;
  TextStyle? get appCaption => labelSmall;
  TextStyle? get appButton => labelLarge;
}
