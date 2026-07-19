import 'package:flutter/material.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/run_metrics.dart';
import 'run_metric_formatters.dart';

class LiveRunMetricsGrid extends StatelessWidget {
  const LiveRunMetricsGrid({required this.metrics, super.key});

  final RunMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppCard(
      key: const ValueKey('run-live-primary-metrics'),
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Distance',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.secondaryText,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: 'Distance ${metrics.distanceKm.distanceLabel} kilometers',
            child: ExcludeSemantics(
              child: Text(
                metrics.distanceKm.distanceLabel,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppMetric(
                  value: metrics.elapsed.timeLabel,
                  label: 'Time',
                ),
              ),
              Expanded(
                child: AppMetric(
                  value: metrics.currentPace.paceLabel,
                  label: 'Pace /km',
                ),
              ),
              Expanded(
                child: AppMetric(
                  value: '${metrics.calories}',
                  label: 'Calories',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LiveBioSignalCard extends StatelessWidget {
  const LiveBioSignalCard({
    required this.heartRate,
    required this.cadence,
    super.key,
  });

  final int cadence;
  final int heartRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      gradient: const LinearGradient(
        colors: [AppPalette.graphite, AppPalette.charcoal],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.favorite_rounded, color: context.appColors.danger),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$heartRate BPM', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$cadence SPM · AEROBIC ZONE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppPalette.smoke,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          AppProgressRing(
            progress: 0.64,
            size: AppLayout.badgeSize,
            strokeWidth: AppSpacing.xs,
            child: Text('Z3', style: theme.textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}

class LiveRunControl extends StatelessWidget {
  const LiveRunControl({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.primary = false,
    super.key,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = primary
        ? AppLayout.avatarLarge
        : AppLayout.navigationCenterAction;
    return Semantics(
      button: true,
      label: label,
      value: primary ? 'Run session control' : null,
      child: Column(
        children: [
          AppPressedScale(
            onTap: onTap,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadii.full),
            ),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary ? color : color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.5)),
                boxShadow: primary
                    ? AppShadows.glow(color, opacity: 0.28)
                    : AppShadows.low(Theme.of(context).brightness),
              ),
              child: Icon(
                icon,
                color: primary ? AppPalette.ink : color,
                size: primary ? AppLayout.iconContainer : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class NoActiveRun extends StatelessWidget {
  const NoActiveRun({
    required this.message,
    required this.onPrepare,
    super.key,
  });

  final String message;
  final VoidCallback onPrepare;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: 'Prepare Run', onPressed: onPrepare),
            ],
          ),
        ),
      ),
    );
  }
}
