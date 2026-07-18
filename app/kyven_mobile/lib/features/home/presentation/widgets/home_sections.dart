import 'package:flutter/material.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';

class DailyChallenge extends StatelessWidget {
  const DailyChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      color: AppPalette.lime,
      borderColor: AppPalette.lime,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY CHALLENGE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppPalette.ink,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Own the last\n2 kilometers.',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppPalette.ink,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.north_east_rounded,
            size: AppLayout.iconContainer,
            color: AppPalette.ink,
          ),
        ],
      ),
    );
  }
}

class TrainingSignal extends StatelessWidget {
  const TrainingSignal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      gradient: const LinearGradient(
        colors: [AppPalette.graphite, AppPalette.steel],
      ),
      child: Row(
        children: [
          AppProgressRing(
            progress: 0.62,
            size: AppLayout.badgeSize,
            strokeWidth: AppSpacing.xs,
            child: const Icon(Icons.bolt_rounded, color: AppPalette.lime),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tempo ignition', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '32 min · Controlled intensity',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppPalette.smoke,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: AppPalette.smoke),
        ],
      ),
    );
  }
}

class AchievementStrip extends StatelessWidget {
  const AchievementStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const badges = [
      (Icons.local_fire_department_rounded, '6 DAY'),
      (Icons.speed_rounded, 'FAST 5K'),
      (Icons.landscape_rounded, 'CLIMBER'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Unlocked energy',
          subtitle: 'Your latest achievements',
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (final badge in badges)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: AppLayout.badgeSize,
                      height: AppLayout.badgeSize,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppPalette.violetDeep,
                            AppPalette.electricDeep,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(badge.$1, color: AppPalette.white),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      badge.$2,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppPalette.smoke,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class RecentRun extends StatelessWidget {
  const RecentRun({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              const AppTag(
                label: 'Yesterday',
                color: AppPalette.electricBright,
              ),
              Text('29:38', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Waterfront flow', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(
                child: AppMetric(value: '5.2 km', label: 'Distance'),
              ),
              Expanded(
                child: AppMetric(value: '5:42', label: 'Pace'),
              ),
              Expanded(
                child: AppMetric(value: '142', label: 'BPM'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
