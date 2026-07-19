import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';

class HomeDashboardSection extends StatelessWidget {
  const HomeDashboardSection({
    required this.title,
    required this.subtitle,
    required this.child,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String? actionLabel;
  final Widget child;
  final VoidCallback? onAction;
  final String subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title. $subtitle',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            title: title,
            subtitle: subtitle,
            action: actionLabel == null || onAction == null
                ? null
                : TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
