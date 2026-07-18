import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/home_dashboard.dart';
import 'home_section_shell.dart';

class TodayActivitySection extends StatelessWidget {
  const TodayActivitySection({required this.metrics, super.key});

  final List<ActivityMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return HomeDashboardSection(
      title: 'Today’s Activity',
      subtitle: 'A quiet snapshot of today’s movement',
      child: GridView.builder(
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
        itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final ActivityMetric metric;

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
