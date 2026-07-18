import 'package:flutter/material.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'design_system_section.dart';

class ColorRolesSection extends StatelessWidget {
  const ColorRolesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colors = [
      ('Background', appColors.background, appColors.primaryText),
      ('Surface', appColors.surface, appColors.primaryText),
      ('Elevated surface', appColors.elevatedSurface, appColors.primaryText),
      ('Primary text', appColors.primaryText, appColors.background),
      ('Secondary text', appColors.secondaryText, appColors.background),
      ('Disabled text', appColors.disabledText, appColors.background),
      ('Accent', appColors.accent, appColors.background),
      ('Success', appColors.success, appColors.background),
      ('Warning', appColors.warning, appColors.background),
      ('Error', appColors.error, appColors.background),
      ('Outline', appColors.outline, appColors.primaryText),
      ('Divider', appColors.divider, appColors.primaryText),
      ('Overlay', appColors.overlay, appColors.primaryText),
    ];

    return DesignSystemSection(
      title: 'Color roles',
      description: 'Semantic colors adapt automatically to the active theme.',
      child: Column(
        children: [
          for (var index = 0; index < colors.length; index++) ...[
            _ColorRole(
              name: colors[index].$1,
              color: colors[index].$2,
              foreground: colors[index].$3,
            ),
            if (index < colors.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ColorRole extends StatelessWidget {
  const _ColorRole({
    required this.name,
    required this.color,
    required this.foreground,
  });

  final Color color;
  final Color foreground;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = color
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .toUpperCase();

    return Semantics(
      label: '$name color, hexadecimal $value',
      child: Row(
        children: [
          Container(
            width: AppLayout.iconContainer,
            height: AppLayout.iconContainer,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadii.control,
            ),
            child: Icon(Icons.circle, color: foreground, size: AppSpacing.md),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(name, style: theme.textTheme.titleSmall)),
          Text('#$value', style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
