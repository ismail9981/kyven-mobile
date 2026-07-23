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

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(evaluatedGoalsProvider);

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: AppResponsiveContent(
        child: goals.when(
          data: (items) => _GoalsContent(goals: items),
          loading: () => const Center(child: AppLoadingIndicator()),
          error: (_, _) => const AppErrorState(
            title: 'Goals unavailable',
            message: 'KYVEN could not load your personal goals.',
          ),
        ),
      ),
    );
  }
}

class _GoalsContent extends StatelessWidget {
  const _GoalsContent({required this.goals});

  final List<GoalEvaluationResult> goals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final activeCount = goals
        .where((result) => result.progress.status == GoalStatus.active)
        .length;

    return SingleChildScrollView(
      key: const PageStorageKey('goals-scroll'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Goals', style: theme.textTheme.displaySmall),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$activeCount active personal goals',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                key: const ValueKey('create-goal-button'),
                label: 'Create',
                onPressed: () => context.goNamed(AppRoute.goalCreate.name),
                icon: Icons.add_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (goals.isEmpty)
            const AppCard(
              key: ValueKey('goals-empty-state'),
              child: AppEmptyState(
                title: 'No goals yet',
                message:
                    'Create a personal target and KYVEN will track it from saved runs.',
                icon: Icons.flag_outlined,
              ),
            )
          else ...[
            _GoalSection(
              title: 'Active',
              emptyTitle: 'No active goals',
              emptyMessage: 'Create a weekly, monthly, or custom goal.',
              goals: _byStatus(goals, GoalStatus.active),
            ),
            _GoalSection(
              title: 'Completed',
              emptyTitle: 'No completed goals',
              emptyMessage: 'Completed goals will collect here.',
              goals: _byStatus(goals, GoalStatus.completed),
            ),
            _GoalSection(
              title: 'Expired',
              emptyTitle: 'No expired goals',
              emptyMessage: 'Goals that end before completion appear here.',
              goals: _byStatus(goals, GoalStatus.expired),
            ),
            _GoalSection(
              title: 'Archived',
              emptyTitle: 'No archived goals',
              emptyMessage: 'Archived goals remain stored locally.',
              goals: _byStatus(goals, GoalStatus.archived),
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  static List<GoalEvaluationResult> _byStatus(
    List<GoalEvaluationResult> goals,
    GoalStatus status,
  ) {
    return goals
        .where((result) => result.progress.status == status)
        .toList(growable: false);
  }
}

class _GoalSection extends StatelessWidget {
  const _GoalSection({
    required this.title,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.goals,
  });

  final String emptyMessage;
  final String emptyTitle;
  final List<GoalEvaluationResult> goals;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: title),
          const SizedBox(height: AppSpacing.md),
          if (goals.isEmpty)
            AppCard(
              child: AppEmptyState(title: emptyTitle, message: emptyMessage),
            )
          else
            for (final result in goals) ...[
              GoalCard(
                result: result,
                onTap: () => context.goNamed(
                  AppRoute.goalDetail.name,
                  pathParameters: {'goalId': result.goal.id},
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}
