import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../run_tracking/domain/entities/motion_insights.dart';
import '../../../run_tracking/presentation/widgets/saved_run_formatters.dart';
import 'home_section_shell.dart';

class WeeklyProgressSection extends StatelessWidget {
  const WeeklyProgressSection({required this.insights, super.key});

  final AsyncValue<MotionInsights> insights;

  @override
  Widget build(BuildContext context) {
    return HomeDashboardSection(
      title: 'Weekly Progress',
      subtitle: 'Monday to Sunday, from local history',
      child: insights.when(
        data: (data) => AppCard(
          key: const ValueKey('home-weekly-progress'),
          variant: AppCardVariant.elevated,
          child: Semantics(
            label:
                'Weekly progress, ${data.weeklyDistanceKm.toStringAsFixed(1)} kilometers this week',
            child: ExcludeSemantics(
              child: SizedBox(
                height: 172,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (
                      var index = 0;
                      index < data.weeklyProgress.length;
                      index++
                    ) ...[
                      Expanded(
                        child: _ProgressBar(day: data.weeklyProgress[index]),
                      ),
                      if (index != data.weeklyProgress.length - 1)
                        const SizedBox(width: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        loading: () => const AppLoadingIndicator(label: 'Loading week'),
        error: (_, _) => const AppStatusBanner(
          status: AppStatus.error,
          title: 'Week unavailable',
          message: 'KYVEN could not calculate weekly progress.',
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.day});

  final MotionWeekDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final progress = day.progress;

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
          day.distanceKm == 0 ? '0' : kilometersLabel(day.distanceKm),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.secondaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
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
