import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/goal_evaluation_result.dart';
import 'goal_formatters.dart';

class GoalCompletionFeedbackCard extends StatelessWidget {
  const GoalCompletionFeedbackCard({required this.results, super.key});

  final List<GoalEvaluationResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }
    final colors = context.appColors;
    final theme = Theme.of(context);

    return AppCard(
      key: const ValueKey('run-summary-goal-completion-card'),
      variant: AppCardVariant.elevated,
      glowColor: colors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTag(
            label: 'Goal Complete',
            color: colors.accent,
            icon: Icons.flag_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            results.length == 1
                ? results.first.goal.title
                : '${results.length} goals completed',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            results
                .map(
                  (result) =>
                      '${GoalFormatters.value(result.progress.targetValue, result.goal.unit)} achieved',
                )
                .join(' • '),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
