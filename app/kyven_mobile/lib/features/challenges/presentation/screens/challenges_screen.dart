import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../gamification/application/gamification_providers.dart';
import '../../../gamification/domain/entities/achievement_definition.dart';
import '../../../gamification/domain/entities/challenge_definition.dart';
import '../../../gamification/domain/entities/challenge_progress.dart';
import '../../../gamification/domain/entities/gamification_dashboard.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(gamificationDashboardProvider);
    return AppScaffold(
      padding: EdgeInsets.zero,
      body: dashboard.when(
        data: (value) => _ChallengesContent(dashboard: value),
        error: (_, _) => const Center(
          child: AppErrorState(
            title: 'Challenges unavailable',
            message: 'KYVEN could not load your local rewards state.',
          ),
        ),
        loading: () => const Center(
          child: AppLoadingIndicator(label: 'Loading challenges'),
        ),
      ),
    );
  }
}

class _ChallengesContent extends StatelessWidget {
  const _ChallengesContent({required this.dashboard});

  final GamificationDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final profile = dashboard.profile;
    final progressById = {
      for (final progress in dashboard.challengeProgress)
        progress.challengeId: progress,
    };
    final weekly = dashboard.challenges
        .where((challenge) => challenge.period == ChallengePeriod.weekly)
        .toList(growable: false);
    final monthly = dashboard.challenges
        .where((challenge) => challenge.period == ChallengePeriod.monthly)
        .toList(growable: false);
    final lifetime = dashboard.challenges
        .where((challenge) => challenge.period == ChallengePeriod.lifetime)
        .toList(growable: false);

    return SingleChildScrollView(
      key: const PageStorageKey('challenges-scroll'),
      child: AppResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTag(
              label: 'Local Rewards',
              color: colors.highlight,
              icon: Icons.emoji_events_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Challenges &\nachievements.',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              key: const ValueKey('gamification-level-header'),
              variant: AppCardVariant.elevated,
              glowColor: colors.info,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${profile.currentLevel}',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${profile.totalXp} total XP',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    child: LinearProgressIndicator(
                      minHeight: AppSpacing.sm,
                      value: profile.xpRequiredForNextLevel == 0
                          ? 0
                          : (profile.xpIntoCurrentLevel /
                                    profile.xpRequiredForNextLevel)
                                .clamp(0, 1),
                      backgroundColor: colors.outline,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppMetric(
                          value: '${profile.currentStreakDays}',
                          label: 'Current Streak',
                        ),
                      ),
                      Expanded(
                        child: AppMetric(
                          value: '${profile.longestStreakDays}',
                          label: 'Longest Streak',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _ChallengeSection(
              title: 'Weekly Challenges',
              challenges: weekly,
              progressById: progressById,
            ),
            const SizedBox(height: AppSpacing.xl),
            _ChallengeSection(
              title: 'Monthly Challenges',
              challenges: monthly,
              progressById: progressById,
            ),
            const SizedBox(height: AppSpacing.xl),
            _ChallengeSection(
              title: 'Lifetime Challenges',
              challenges: lifetime,
              progressById: progressById,
            ),
            const SizedBox(height: AppSpacing.xl),
            _AchievementSection(dashboard: dashboard),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

class _ChallengeSection extends StatelessWidget {
  const _ChallengeSection({
    required this.title,
    required this.challenges,
    required this.progressById,
  });

  final List<ChallengeDefinition> challenges;
  final Map<String, ChallengeProgress> progressById;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title, subtitle: 'Progress updates locally'),
        const SizedBox(height: AppSpacing.md),
        for (final challenge in challenges) ...[
          _ChallengeCard(
            challenge: challenge,
            progress: progressById[challenge.id],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, required this.progress});

  final ChallengeDefinition challenge;
  final ChallengeProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final value = progress?.currentValue ?? 0;
    final target = progress?.targetValue ?? challenge.targetValue;
    final completed = progress?.isCompleted ?? false;
    return AppCard(
      key: ValueKey('challenge-${challenge.id}'),
      borderColor: completed ? colors.success : colors.outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(challenge.title, style: theme.textTheme.titleLarge),
              ),
              AppTag(label: '+${challenge.xpReward} XP', color: colors.accent),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            challenge.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.full),
            child: LinearProgressIndicator(
              key: ValueKey('challenge-progress-${challenge.id}'),
              minHeight: AppSpacing.sm,
              value: progress?.progressFraction ?? 0,
              backgroundColor: colors.outline,
              color: completed ? colors.success : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${_format(value)} / ${_format(target)} ${_unitLabel(challenge.unit)}',
          ),
          if (completed) ...[
            const SizedBox(height: AppSpacing.sm),
            AppTag(
              label: 'Completed',
              color: colors.success,
              icon: Icons.check_rounded,
            ),
          ],
        ],
      ),
    );
  }

  String _format(double value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

  String _unitLabel(ChallengeUnit unit) => switch (unit) {
    ChallengeUnit.kilometers => 'km',
    ChallengeUnit.runs => 'runs',
    ChallengeUnit.minutes => 'min',
    ChallengeUnit.sessions => 'sessions',
    ChallengeUnit.days => 'days',
  };
}

class _AchievementSection extends StatelessWidget {
  const _AchievementSection({required this.dashboard});

  final GamificationDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final unlocked = dashboard.profile.unlockedAchievements;
    final unlockedById = {
      for (final item in unlocked) item.achievementId: item,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionHeader(
          title: 'Achievements',
          subtitle: 'Unlocked and upcoming milestones',
        ),
        const SizedBox(height: AppSpacing.md),
        for (final achievement in dashboard.achievements) ...[
          _AchievementCard(
            achievement: achievement,
            unlockedAt: unlockedById[achievement.id]?.unlockedAt,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, this.unlockedAt});

  final AchievementDefinition achievement;
  final DateTime? unlockedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final unlocked = unlockedAt != null;
    return AppCard(
      key: ValueKey('achievement-${achievement.id}'),
      color: unlocked ? null : colors.surface,
      borderColor: unlocked ? colors.success : colors.outline,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            unlocked
                ? Icons.workspace_premium_rounded
                : Icons.lock_outline_rounded,
            color: unlocked ? colors.success : colors.secondaryText,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  achievement.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  unlocked
                      ? 'Unlocked ${unlockedAt!.month}/${unlockedAt!.day}/${unlockedAt!.year}'
                      : 'Locked · +${achievement.xpReward} XP',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
