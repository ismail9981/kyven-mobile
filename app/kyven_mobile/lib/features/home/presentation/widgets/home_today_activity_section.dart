import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../run_tracking/domain/entities/motion_insights.dart';
import '../../../run_tracking/presentation/widgets/run_metric_formatters.dart';
import '../../../run_tracking/presentation/widgets/saved_run_formatters.dart';
import 'home_section_shell.dart';

class TodayActivitySection extends StatelessWidget {
  const TodayActivitySection({required this.insights, super.key});

  final AsyncValue<MotionInsights> insights;

  @override
  Widget build(BuildContext context) {
    return HomeDashboardSection(
      title: 'Today’s Activity',
      subtitle: 'Built from runs saved today',
      child: insights.when(
        data: (data) {
          if (!data.hasRunsToday) {
            return const AppCard(
              key: ValueKey('home-today-empty-state'),
              child: AppEmptyState(
                title: 'Nothing recorded today',
                message: 'Ready for your next adventure?',
                icon: Icons.bolt_rounded,
                iconColor: AppPalette.electricBright,
              ),
            );
          }

          final metrics = [
            _ActivityMetric(
              label: 'Today’s Runs',
              value: '${data.todayRuns}',
              semanticValue: '${data.todayRuns} runs today',
            ),
            _ActivityMetric(
              label: 'Distance',
              value: kilometersLabel(data.todayDistanceKm),
              semanticValue:
                  '${data.todayDistanceKm.toStringAsFixed(1)} kilometers today',
            ),
            _ActivityMetric(
              label: 'Duration',
              value: data.todayDuration.timeLabel,
              semanticValue: '${data.todayDuration.timeLabel} total duration',
            ),
            _ActivityMetric(
              label: 'Calories',
              value: '${data.todayCalories}',
              semanticValue: '${data.todayCalories} calories today',
            ),
          ];

          return GridView.builder(
            key: const ValueKey('home-today-activity-grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) =>
                _MetricCard(metric: metrics[index]),
          );
        },
        loading: () => const AppLoadingIndicator(label: 'Loading today'),
        error: (_, _) => const AppStatusBanner(
          status: AppStatus.error,
          title: 'Today unavailable',
          message: 'KYVEN could not calculate today’s activity.',
        ),
      ),
    );
  }
}

class _ActivityMetric {
  const _ActivityMetric({
    required this.label,
    required this.value,
    required this.semanticValue,
  });

  final String label;
  final String semanticValue;
  final String value;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _ActivityMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      semanticLabel: '${metric.label}, ${metric.semanticValue}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            metric.value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            metric.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
