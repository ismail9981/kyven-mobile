import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/goal_evaluation_result.dart';
import '../../domain/entities/personal_goal.dart';
import 'goal_formatters.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({required this.result, this.onTap, super.key});

  final VoidCallback? onTap;
  final GoalEvaluationResult result;

  @override
  Widget build(BuildContext context) {
    final goal = result.goal;
    final progress = result.progress;
    final theme = Theme.of(context);
    final colors = context.appColors;
    final statusColor = switch (progress.status) {
      GoalStatus.completed => colors.success,
      GoalStatus.expired => colors.warning,
      GoalStatus.archived => colors.secondaryText,
      GoalStatus.active => progress.isOnTrack ? colors.accent : colors.warning,
    };

    return AppCard(
      key: ValueKey('goal-card-${goal.id}'),
      variant: AppCardVariant.interactive,
      onTap: onTap,
      semanticLabel:
          '${goal.title}, ${GoalFormatters.statusLabel(progress.status)}, ${(progress.progressFraction * 100).round()} percent complete',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(goal.title, style: theme.textTheme.titleLarge),
              ),
              AppTag(
                label: GoalFormatters.statusLabel(progress.status),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            GoalFormatters.typeLabel(goal.type),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LinearProgressIndicator(
            value: progress.progressFraction,
            minHeight: AppSpacing.sm,
            backgroundColor: colors.outline,
            color: statusColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${GoalFormatters.value(progress.currentValue, goal.unit)} / ${GoalFormatters.value(progress.targetValue, goal.unit)}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                '${(progress.progressFraction * 100).round()}%',
                style: theme.textTheme.labelLarge?.copyWith(color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppTag(
                label: GoalFormatters.periodLabel(goal.periodType),
                color: colors.info,
                icon: Icons.calendar_month_rounded,
              ),
              AppTag(
                label: progress.daysRemaining == 1
                    ? '1 day left'
                    : '${progress.daysRemaining} days left',
                color: colors.highlight,
                icon: Icons.timelapse_rounded,
              ),
              AppTag(
                label: progress.isOnTrack ? 'On Track' : 'Behind Pace',
                color: progress.isOnTrack ? colors.success : colors.warning,
                icon: progress.isOnTrack
                    ? Icons.trending_up_rounded
                    : Icons.priority_high_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
