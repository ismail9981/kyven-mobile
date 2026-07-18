import 'package:flutter/material.dart';

import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_colors.dart';

enum AppStatus { success, warning, error, info }

class AppStatusBanner extends StatelessWidget {
  const AppStatusBanner({
    required this.status,
    required this.title,
    required this.message,
    super.key,
  });

  final String message;
  final AppStatus status;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon) = switch (status) {
      AppStatus.success => (context.appColors.success, Icons.check_circle),
      AppStatus.warning => (context.appColors.warning, Icons.warning_rounded),
      AppStatus.error => (context.appColors.error, Icons.error_rounded),
      AppStatus.info => (context.appColors.info, Icons.info_rounded),
    };

    return Semantics(
      container: true,
      label: '$title. $message',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadii.card,
          border: Border.all(color: color),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.appColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
