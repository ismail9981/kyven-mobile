import 'package:flutter/material.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import 'design_system_section.dart';

class FoundationsSection extends StatelessWidget {
  const FoundationsSection({super.key});

  static const _spacings = [
    ('XS', AppSpacing.xs),
    ('SM', AppSpacing.sm),
    ('MD', AppSpacing.md),
    ('LG', AppSpacing.lg),
    ('XL', AppSpacing.xl),
    ('XXL', AppSpacing.xxl),
  ];
  static const _radii = [
    ('XS', AppRadii.xs),
    ('SM', AppRadii.sm),
    ('MD', AppRadii.md),
    ('LG', AppRadii.lg),
    ('XL', AppRadii.xl),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        DesignSystemSection(
          title: 'Spacing',
          child: Column(
            children: [
              for (var index = 0; index < _spacings.length; index++) ...[
                Row(
                  children: [
                    SizedBox(
                      width: AppLayout.iconContainer,
                      child: Text(
                        _spacings[index].$1,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                    Container(
                      width: _spacings[index].$2,
                      height: AppSpacing.lg,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('${_spacings[index].$2.toInt()} px'),
                  ],
                ),
                if (index < _spacings.length - 1)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        DesignSystemSection(
          title: 'Radius',
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final radius in _radii)
                Column(
                  children: [
                    Container(
                      width: AppLayout.emphasizedNavigationSize,
                      height: AppLayout.emphasizedNavigationSize,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(radius.$2),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(radius.$1, style: theme.textTheme.labelSmall),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        DesignSystemSection(
          title: 'Shadows and elevation',
          child: Row(
            children: [
              Expanded(
                child: _ShadowSample(
                  label: 'Low',
                  shadows: AppShadows.low(theme.brightness),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _ShadowSample(
                  label: 'High',
                  shadows: AppShadows.high(theme.brightness),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShadowSample extends StatelessWidget {
  const _ShadowSample({required this.label, required this.shadows});

  final String label;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: AppLayout.avatarLarge,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadii.card,
        boxShadow: shadows,
      ),
      child: Text(label, style: theme.textTheme.labelLarge),
    );
  }
}
