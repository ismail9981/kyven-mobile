import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/goals_providers.dart';
import '../../domain/entities/goal_evaluation_result.dart';
import '../../domain/entities/personal_goal.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_formatters.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({required this.goalId, super.key});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(selectedGoalProvider(goalId));

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: AppResponsiveContent(
        child: goal.when(
          data: (result) => result == null
              ? const AppEmptyState(
                  title: 'Goal not found',
                  message: 'This personal goal is no longer available.',
                )
              : _GoalDetail(result: result),
          error: (_, _) => const AppErrorState(
            title: 'Goal unavailable',
            message: 'KYVEN could not load this goal.',
          ),
          loading: () => const Center(child: AppLoadingIndicator()),
        ),
      ),
    );
  }
}

class _GoalDetail extends ConsumerWidget {
  const _GoalDetail({required this.result});

  final GoalEvaluationResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = result.goal;
    final progress = result.progress;
    final theme = Theme.of(context);
    final colors = context.appColors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Goal Details', style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.xl),
          GoalCard(result: result),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppMetric(
                  value: GoalFormatters.value(
                    progress.remainingValue,
                    goal.unit,
                  ),
                  label: 'Remaining',
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  GoalFormatters.range(goal.startAt, goal.endAt),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${GoalFormatters.periodLabel(goal.periodType)} • ${GoalFormatters.statusLabel(progress.status)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (goal.isEditable) ...[
            AppButton(
              key: const ValueKey('edit-goal-button'),
              label: 'Edit Goal',
              onPressed: () => context.goNamed(
                AppRoute.goalEdit.name,
                pathParameters: {'goalId': goal.id},
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AppButton(
            key: const ValueKey('archive-goal-button'),
            label: 'Archive Goal',
            onPressed: goal.status == GoalStatus.archived
                ? null
                : () async {
                    await ref
                        .read(goalsCoordinatorProvider)
                        .archiveGoal(goal.id);
                    if (context.mounted) {
                      context.goNamed(AppRoute.goals.name);
                    }
                  },
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    );
  }
}
