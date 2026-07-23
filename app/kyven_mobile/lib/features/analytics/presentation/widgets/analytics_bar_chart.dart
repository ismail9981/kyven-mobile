import 'package:flutter/material.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/analytics_trend.dart';

class AnalyticsBarChart extends StatelessWidget {
  const AnalyticsBarChart({
    required this.trend,
    required this.semanticLabel,
    this.height = 156,
    this.valueSuffix = '',
    super.key,
  });

  final double height;
  final String semanticLabel;
  final AnalyticsTrend trend;
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final max = trend.max <= 0 ? 1 : trend.max;

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final point in trend.points) ...[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: point.value / max),
                            duration: AppDurations.slow,
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) =>
                                FractionallySizedBox(
                                  heightFactor: value.clamp(0.04, 1),
                                  alignment: Alignment.bottomCenter,
                                  child: child,
                                ),
                            child: Container(
                              width: AppSpacing.xl,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppRadii.full),
                                  bottom: Radius.circular(AppRadii.md),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    theme.colorScheme.primary.withValues(
                                      alpha: 0.38,
                                    ),
                                    point.value > 0
                                        ? colors.accent
                                        : colors.outline,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        point.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                      Text(
                        valueSuffix.isEmpty
                            ? point.value.toStringAsFixed(0)
                            : '${point.value.toStringAsFixed(1)}$valueSuffix',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (point != trend.points.last)
                  const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
