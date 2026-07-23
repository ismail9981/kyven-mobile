import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/analytics_comparison.dart';
import '../../domain/entities/run_period_summary.dart';
import 'analytics_formatters.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  const AnalyticsSummaryCard({
    required this.summary,
    required this.comparison,
    required this.title,
    super.key,
  });

  final AnalyticsComparison comparison;
  final RunPeriodSummary summary;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = AnalyticsFormatters.periodLabel(
      summary.period.start,
      summary.period.end.subtract(const Duration(days: 1)),
    );

    return AppCard(
      key: const ValueKey('analytics-summary-card'),
      showShadow: true,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.24),
          AppPalette.violet.withValues(alpha: 0.12),
          AppPalette.transparent,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(period, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AnalyticsFormatters.distance(summary.totalDistanceKm),
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              AppMetric(
                value: AnalyticsFormatters.runs(summary.runCount),
                label: 'Runs',
              ),
              AppMetric(
                value: AnalyticsFormatters.duration(summary.totalDuration),
                label: 'Duration',
              ),
              AppMetric(
                value: AnalyticsFormatters.calories(summary.totalCalories),
                label: 'Calories',
              ),
              AppMetric(
                value: AnalyticsFormatters.pace(summary.averagePace),
                label: 'Avg Pace',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTag(
            label: AnalyticsFormatters.change(
              comparison.distanceChangePercent,
              improvementMode: false,
            ),
            color: comparison.hasDistanceComparison
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
