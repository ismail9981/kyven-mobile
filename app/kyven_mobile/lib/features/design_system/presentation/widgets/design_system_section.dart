import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';

class DesignSystemSection extends StatelessWidget {
  const DesignSystemSection({
    required this.title,
    required this.child,
    this.description,
    super.key,
  });

  final Widget child;
  final String? description;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title, subtitle: description),
        const SizedBox(height: AppSpacing.md),
        AppCard(child: child),
      ],
    );
  }
}
