import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/saved_run.dart';
import 'run_metric_formatters.dart';
import 'saved_run_formatters.dart';

class SavedRunCard extends StatelessWidget {
  const SavedRunCard({required this.run, this.onTap, super.key});

  final VoidCallback? onTap;
  final SavedRun run;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppCard(
      key: ValueKey('saved-run-card-${run.id}'),
      variant: AppCardVariant.interactive,
      semanticLabel: run.accessibilityLabel,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Motion Session',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Text(
                compactDateLabel(run.completedAt),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppMetric(
                  value: kilometersLabel(run.distanceKm),
                  label: 'Distance',
                ),
              ),
              Expanded(
                child: AppMetric(value: run.duration.timeLabel, label: 'Time'),
              ),
              Expanded(
                child: AppMetric(
                  value: run.averagePace.paceLabel,
                  label: 'Avg Pace',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: AppPalette.lime,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${run.calories} calories',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
