import 'package:flutter/material.dart';

import '../../core/theme/app_layout.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_colors.dart';
import 'app_pressed_scale.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.color,
    super.key,
  });

  final Color? color;
  final IconData icon;
  final VoidCallback onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = color ?? colors.accent;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: AppPressedScale(
        onTap: onPressed,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.full)),
        child: Container(
          width: AppLayout.minimumTapTarget,
          height: AppLayout.minimumTapTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            shape: BoxShape.circle,
            border: Border.all(color: colors.outline),
            boxShadow: AppShadows.low(Theme.of(context).brightness),
          ),
          child: Icon(icon, color: accent, size: AppSpacing.xl),
        ),
      ),
    );
  }
}
