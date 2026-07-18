import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/home_dashboard.dart';
import 'home_section_shell.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({required this.activities, super.key});

  final List<RecentActivity> activities;

  @override
  Widget build(BuildContext context) {
    return HomeDashboardSection(
      title: 'Recent Activity',
      subtitle: 'Previous runs, kept simple',
      child: Column(
        key: const ValueKey('home-recent-activity-list'),
        children: [
          for (var index = 0; index < activities.length; index++) ...[
            _RecentActivityCard(activity: activities[index]),
            if (index != activities.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.activity});

  final RecentActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppCard(
      variant: AppCardVariant.elevated,
      semanticLabel:
          '${activity.title}, ${activity.distance}, ${activity.duration}, '
          '${activity.pace}, ${activity.date}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(activity.title, style: theme.textTheme.titleLarge),
              ),
              Text(
                activity.date,
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
                child: AppMetric(value: activity.distance, label: 'Distance'),
              ),
              Expanded(
                child: AppMetric(value: activity.duration, label: 'Duration'),
              ),
              Expanded(
                child: AppMetric(value: activity.pace, label: 'Pace'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
