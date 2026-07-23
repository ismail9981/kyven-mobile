import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/gamification_update_result.dart';

class GamificationRewardCard extends StatelessWidget {
  const GamificationRewardCard({required this.result, super.key});

  final GamificationUpdateResult result;

  @override
  Widget build(BuildContext context) {
    if (!result.hasRewards) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final colors = context.appColors;
    return AppCard(
      key: const ValueKey('gamification-reward-card'),
      semanticLabel: 'Reward summary',
      variant: AppCardVariant.elevated,
      glowColor: colors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTag(
            label: 'Rewards',
            icon: Icons.bolt_rounded,
            color: colors.accent,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '+${result.xpGranted} XP',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          if (result.didLevelUp) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Level ${result.levelAfter} reached',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.success,
              ),
            ),
          ],
          if (result.newlyCompletedChallenges.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final challenge in result.newlyCompletedChallenges.take(2))
              Text('Challenge complete: ${challenge.title}'),
          ],
          if (result.newlyUnlockedAchievements.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final achievement in result.newlyUnlockedAchievements.take(2))
              Text('Achievement unlocked: ${achievement.title}'),
          ],
        ],
      ),
    );
  }
}
