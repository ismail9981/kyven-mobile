import 'package:flutter/material.dart';

import '../../core/theme/app_durations.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_colors.dart';
import 'app_pressed_scale.dart';

enum AppButtonVariant { primary, secondary, ghost, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final IconData? icon;
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final enabled = onPressed != null && !isLoading;
    final (background, foreground, border) = switch (variant) {
      AppButtonVariant.primary => (
        theme.colorScheme.primary,
        theme.colorScheme.onPrimary,
        theme.colorScheme.primary,
      ),
      AppButtonVariant.secondary => (
        colors.elevatedSurface,
        theme.colorScheme.onSurface,
        colors.outline,
      ),
      AppButtonVariant.ghost => (
        AppPalette.transparent,
        theme.colorScheme.primary,
        AppPalette.transparent,
      ),
      AppButtonVariant.destructive => (
        colors.error,
        theme.colorScheme.onError,
        colors.error,
      ),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.45,
        duration: AppDurations.fast,
        child: AppPressedScale(
          onTap: enabled ? onPressed : null,
          borderRadius: AppRadii.control,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: AppRadii.control,
              border: Border.all(color: border),
              boxShadow: variant == AppButtonVariant.primary && enabled
                  ? AppShadows.glow(theme.colorScheme.primary, opacity: 0.12)
                  : null,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppLayout.controlHeight,
                minWidth: AppLayout.minimumTapTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox.square(
                          dimension: AppSpacing.xl,
                          child: CircularProgressIndicator(
                            strokeWidth: AppSpacing.xxs,
                            color: foreground,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon case final icon?) ...[
                              Icon(icon, color: foreground),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            Flexible(
                              child: Text(
                                label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: foreground,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
