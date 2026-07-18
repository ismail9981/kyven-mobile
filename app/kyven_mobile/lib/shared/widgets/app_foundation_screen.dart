import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'app_responsive_content.dart';
import 'app_scaffold.dart';

class AppFoundationScreen extends StatelessWidget {
  const AppFoundationScreen({
    required this.title,
    required this.description,
    super.key,
  });

  final String description;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      body: AppResponsiveContent(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              Text(description, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
