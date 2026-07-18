import 'package:flutter/material.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/home_dashboard.dart';
import 'home_section_shell.dart';

class WeeklyProgressSection extends StatelessWidget {
  const WeeklyProgressSection({required this.days, super.key});

  final List<WeeklyProgressDay> days;

  @override
  Widget build(BuildContext context) {
    return HomeDashboardSection(
      title: 'Weekly Progress',
      subtitle: 'Seven-day motion without the noise',
      child: AppCard(
        key: const ValueKey('home-weekly-progress'),
        variant: AppCardVariant.elevated,
        child: Semantics(
          label: 'Weekly progress for the last seven days',
          child: ExcludeSemantics(
            child: SizedBox(
              height: 156,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var index = 0; index < days.length; index++) ...[
                    Expanded(child: _ProgressBar(day: days[index])),
                    if (index != days.length - 1)
                      const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.day});

  final WeeklyProgressDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final progress = day.progress.clamp(0, 1).toDouble();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: AppDurations.slow,
              curve: AppCurves.standard,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  heightFactor: value,
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                    child: const SizedBox(width: double.infinity),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          day.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.secondaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
