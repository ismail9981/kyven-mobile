import 'package:flutter/material.dart';

import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_colors.dart';
import 'app_pressed_scale.dart';

enum AppCardVariant { standard, elevated, interactive }

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.variant = AppCardVariant.standard,
    this.color,
    this.gradient,
    this.semanticLabel,
    this.showShadow = false,
    this.borderColor,
    this.glowColor,
    super.key,
  });

  final Color? borderColor;
  final Widget child;
  final Color? color;
  final Color? glowColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;
  final bool showShadow;
  final AppCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final isElevated =
        showShadow ||
        variant == AppCardVariant.elevated ||
        variant == AppCardVariant.interactive;
    final content = Padding(padding: padding, child: child);

    return Semantics(
      container: true,
      label: semanticLabel,
      child: AppPressedScale(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: gradient == null
                ? color ??
                      (isElevated ? colors.elevatedSurface : colors.surface)
                : null,
            gradient: gradient,
            borderRadius: AppRadii.card,
            border: Border.all(color: borderColor ?? colors.outline),
            boxShadow: [
              if (isElevated) ...AppShadows.high(theme.brightness),
              if (glowColor case final glow?)
                ...AppShadows.glow(glow, opacity: 0.12),
            ],
          ),
          child: ClipRRect(borderRadius: AppRadii.card, child: content),
        ),
      ),
    );
  }
}
