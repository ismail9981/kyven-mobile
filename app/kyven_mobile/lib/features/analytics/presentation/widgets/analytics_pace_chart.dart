import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/analytics_trend.dart';
import 'analytics_formatters.dart';

class AnalyticsPaceChart extends StatelessWidget {
  const AnalyticsPaceChart({required this.trend, super.key});

  final AnalyticsTrend trend;

  @override
  Widget build(BuildContext context) {
    if (trend.points.isEmpty) {
      return Text(
        'Pace trend appears after your first timed run.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: context.appColors.secondaryText,
        ),
      );
    }

    final fastest = trend.min <= 0 ? 1.0 : trend.min;
    final slowest = trend.max <= fastest ? fastest + 1.0 : trend.max;

    return Semantics(
      label: 'Pace trend chart with ${trend.points.length} recent runs',
      child: ExcludeSemantics(
        child: Column(
          children: [
            for (final point in trend.points)
              _PaceRow(point: point, fastest: fastest, slowest: slowest),
          ],
        ),
      ),
    );
  }
}

class _PaceRow extends StatelessWidget {
  const _PaceRow({
    required this.point,
    required this.fastest,
    required this.slowest,
  });

  final double fastest;
  final AnalyticsDataPoint point;
  final double slowest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final normalized = 1 - ((point.value - fastest) / (slowest - fastest));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(point.label, style: theme.textTheme.labelMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadii.full),
              ),
              child: LinearProgressIndicator(
                minHeight: AppSpacing.sm,
                value: normalized.clamp(0.08, 1),
                backgroundColor: colors.outline,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            AnalyticsFormatters.pace(Duration(seconds: point.value.round())),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
