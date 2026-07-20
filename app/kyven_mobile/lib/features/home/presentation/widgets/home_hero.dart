import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../run_tracking/domain/entities/motion_insights.dart';
import '../../../run_tracking/presentation/widgets/saved_run_formatters.dart';
import '../../domain/entities/home_dashboard.dart';

class GreetingHero extends StatelessWidget {
  const GreetingHero({
    required this.dashboard,
    required this.message,
    super.key,
  });

  final HomeDashboard dashboard;
  final AsyncValue<DashboardMessage> message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final currentMessage = message.asData?.value;
    final title = currentMessage?.title ?? 'Good morning.';
    final subtitle =
        currentMessage?.subtitle ?? 'Loading your movement rhythm.';

    return Semantics(
      header: true,
      label: '$title ${dashboard.runnerName}. $subtitle',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    dashboard.runnerName,
                    style: theme.textTheme.displaySmall?.copyWith(
                      height: 0.98,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Container(
              width: AppLayout.avatarSmall,
              height: AppLayout.avatarSmall,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.elevatedSurface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.glassBorder),
              ),
              child: const AppKyvenMark(
                color: AppPalette.electricBright,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StartRunHeroCard extends StatelessWidget {
  const StartRunHeroCard({
    required this.dashboard,
    required this.insights,
    required this.onStartRun,
    super.key,
  });

  final HomeDashboard dashboard;
  final AsyncValue<MotionInsights> insights;
  final VoidCallback onStartRun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = insights.asData?.value ?? MotionInsights.empty();
    final progress = data.weeklyGoalProgress;

    return Semantics(
      container: true,
      label:
          'Start Run. ${data.weeklyDistanceKm.toStringAsFixed(1)} kilometers this week. '
          '${data.currentStreakDays} day streak.',
      child: AppCard(
        key: const ValueKey('home-start-run-card'),
        showShadow: true,
        glowColor: AppPalette.electricBright,
        borderColor: AppPalette.electricBright.withValues(alpha: 0.6),
        padding: const EdgeInsets.all(AppSpacing.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPalette.electricCore,
            AppPalette.electricDeep,
            AppPalette.violetDeep,
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < AppLayout.compactBreakpoint;
            final ring = AppProgressRing(
              progress: progress,
              size: compact ? 164 : AppLayout.heroRing,
              strokeWidth: AppSpacing.md,
              trackColor: AppPalette.white.withValues(alpha: 0.16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.weeklyDistanceKm.toStringAsFixed(1),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: AppPalette.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'KM WEEK',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppPalette.cloud,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            );
            final content = Column(
              crossAxisAlignment: compact
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Run',
                  textAlign: compact ? TextAlign.center : TextAlign.start,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppPalette.white,
                    height: 0.98,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'A clean launch into today’s movement.',
                  textAlign: compact ? TextAlign.center : TextAlign.start,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppPalette.cloud,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _HeroPill(
                      icon: Icons.local_fire_department_rounded,
                      label: data.currentStreakDays == 0
                          ? 'No streak yet'
                          : '${data.currentStreakDays} day streak',
                    ),
                    _HeroPill(
                      icon: Icons.flag_rounded,
                      label:
                          '${kilometersLabel(data.weeklyGoalKm)} weekly rhythm',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  key: const ValueKey('home-start-run-button'),
                  label: 'Start Run',
                  onPressed: onStartRun,
                  icon: Icons.play_arrow_rounded,
                ),
              ],
            );

            if (compact) {
              return Column(
                children: [
                  ring,
                  const SizedBox(height: AppSpacing.xl),
                  content,
                ],
              );
            }

            return Row(
              children: [
                ring,
                const SizedBox(width: AppSpacing.xl),
                Expanded(child: content),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        border: Border.all(color: AppPalette.white.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppPalette.cloud, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppPalette.cloud),
            ),
          ],
        ),
      ),
    );
  }
}
