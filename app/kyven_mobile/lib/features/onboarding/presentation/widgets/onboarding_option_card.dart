import 'package:flutter/material.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';

class OnboardingOptionCard extends StatelessWidget {
  const OnboardingOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.selectedKey,
    super.key,
  });

  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final Key? selectedKey;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final selectedColor = theme.colorScheme.primary;

    return Semantics(
      button: true,
      selected: selected,
      label: title,
      hint: selected ? 'Selected' : 'Double tap to select',
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        child: AppCard(
          variant: AppCardVariant.interactive,
          onTap: onTap,
          borderColor: selected ? selectedColor : colors.outline,
          glowColor: selected ? selectedColor : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: AppDurations.fast,
                curve: AppCurves.standard,
                decoration: BoxDecoration(
                  color: selected
                      ? selectedColor.withValues(alpha: 0.16)
                      : colors.overlay,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color: selected ? selectedColor : colors.glassBorder,
                  ),
                ),
                child: SizedBox.square(
                  dimension: 48,
                  child: Icon(
                    icon,
                    color: selected ? selectedColor : colors.secondaryText,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AnimatedSwitcher(
                duration: AppDurations.fast,
                child: selected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: selectedKey,
                        color: selectedColor,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        color: colors.disabledText,
                        semanticLabel: 'Not selected',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
