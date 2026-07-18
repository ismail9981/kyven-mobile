import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/color_roles_section.dart';
import '../widgets/component_previews_section.dart';
import '../widgets/controls_section.dart';
import '../widgets/feedback_section.dart';
import '../widgets/foundations_section.dart';
import '../widgets/typography_section.dart';

class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Design System')),
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        child: AppResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'KYVEN foundations',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'A development-only visual reference for shared tokens and components.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const ColorRolesSection(),
              const SizedBox(height: AppSpacing.xl),
              const TypographySection(),
              const SizedBox(height: AppSpacing.xl),
              const FoundationsSection(),
              const SizedBox(height: AppSpacing.xl),
              const ControlsSection(),
              const SizedBox(height: AppSpacing.xl),
              const ComponentPreviewsSection(),
              const SizedBox(height: AppSpacing.xl),
              const FeedbackSection(),
            ],
          ),
        ),
      ),
    );
  }
}
