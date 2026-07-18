import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import 'design_system_section.dart';

class ComponentPreviewsSection extends StatelessWidget {
  const ComponentPreviewsSection({super.key});

  Future<void> _showDialog(BuildContext context) async {
    await AppDialog.show<void>(
      context: context,
      title: 'Dialog preview',
      content: const Text(
        'Dialogs use the shared radius, spacing, typography, and surface tokens.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _showBottomSheet(BuildContext context) async {
    await AppBottomSheet.show<void>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bottom-sheet preview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'This surface is safe-area aware and responds to the keyboard inset.',
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesignSystemSection(
      title: 'Cards and surfaces',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppCard(
            showShadow: true,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.layers_outlined),
              title: Text('Reusable card'),
              subtitle: Text('Optional interaction, color, and elevation'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Preview dialog',
            variant: AppButtonVariant.secondary,
            onPressed: () => _showDialog(context),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Preview bottom sheet',
            variant: AppButtonVariant.secondary,
            onPressed: () => _showBottomSheet(context),
          ),
        ],
      ),
    );
  }
}
