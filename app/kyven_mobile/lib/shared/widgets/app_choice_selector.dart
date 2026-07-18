import 'package:flutter/material.dart';

import '../../core/theme/app_durations.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import 'app_pressed_scale.dart';

class AppChoiceOption<T> {
  const AppChoiceOption({required this.value, required this.label, this.icon});

  final IconData? icon;
  final String label;
  final T value;
}

class AppChoiceSelector<T> extends StatelessWidget {
  const AppChoiceSelector({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ValueChanged<T> onSelected;
  final List<AppChoiceOption<T>> options;
  final T selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          Semantics(
            button: true,
            selected: option.value == selected,
            child: AppPressedScale(
              key: ValueKey(option.value),
              onTap: () => onSelected(option.value),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadii.full),
              ),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: option.value == selected
                      ? AppPalette.electricBright
                      : AppPalette.graphite.withValues(alpha: 0.78),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.full),
                  ),
                  border: Border.all(
                    color: option.value == selected
                        ? AppPalette.electricBright
                        : AppPalette.steel,
                  ),
                  boxShadow: option.value == selected
                      ? AppShadows.glow(
                          AppPalette.electricBright,
                          opacity: 0.14,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.icon case final icon?) ...[
                      Icon(
                        icon,
                        size: AppSpacing.lg,
                        color: option.value == selected
                            ? AppPalette.ink
                            : AppPalette.smoke,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      option.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: option.value == selected
                            ? AppPalette.ink
                            : AppPalette.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
