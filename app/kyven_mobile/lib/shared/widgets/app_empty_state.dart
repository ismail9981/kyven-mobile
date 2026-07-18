import 'package:flutter/material.dart';

import '../../core/theme/app_layout.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_colors.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String? actionLabel;
  final IconData? icon;
  final Color? iconColor;
  final String message;
  final VoidCallback? onAction;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Semantics(
      container: true,
      label: '$title. $message',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon case final icon?) ...[
            Container(
              width: AppLayout.iconContainer,
              height: AppLayout.iconContainer,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.elevatedSurface,
                borderRadius: AppRadii.control,
                border: Border.all(color: colors.outline),
              ),
              child: Icon(icon, color: iconColor ?? colors.accent),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.secondaryText,
            ),
          ),
          if (actionLabel case final label? when onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: label, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
