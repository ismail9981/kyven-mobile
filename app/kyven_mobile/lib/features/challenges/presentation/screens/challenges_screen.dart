import 'package:flutter/material.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        key: const PageStorageKey('challenges-scroll'),
        child: AppResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTag(
                label: '2 active quests',
                color: AppPalette.violet,
                icon: Icons.emoji_events_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Chase what\nmoves you.',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _DistanceQuest(),
              const SizedBox(height: AppSpacing.md),
              const Row(
                children: [
                  Expanded(child: _StreakQuest()),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: _RankTile()),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(
                title: 'Collective pulse',
                subtitle: 'Muscat runners · Live preview',
              ),
              const SizedBox(height: AppSpacing.md),
              const _CommunityQuest(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DistanceQuest extends StatelessWidget {
  const _DistanceQuest();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      showShadow: true,
      glowColor: AppPalette.violet,
      padding: const EdgeInsets.all(AppSpacing.xl),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppPalette.violetDeep, AppPalette.electricDeep],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              Text(
                'JULY / DISTANCE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppPalette.cloud,
                  letterSpacing: 1.2,
                ),
              ),
              const Icon(Icons.arrow_outward_rounded, color: AppPalette.white),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppProgressRing(
                progress: 0.68,
                size: AppLayout.heroRing,
                strokeWidth: AppSpacing.md,
                trackColor: AppPalette.white.withValues(alpha: 0.14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('68', style: theme.textTheme.headlineLarge),
                    Text(
                      'OF 100 KM',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppPalette.cloud,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '32 km\nto glory.',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AppTag(label: 'Top 18%', color: AppPalette.lime),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakQuest extends StatelessWidget {
  const _StreakQuest();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      color: AppPalette.lime,
      borderColor: AppPalette.lime,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wb_sunny_rounded, color: AppPalette.ink),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '3 / 4',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppPalette.ink,
            ),
          ),
          Text(
            'SUNRISE RUNS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppPalette.ink,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.trending_up_rounded,
            color: AppPalette.electricBright,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('#184', style: theme.textTheme.headlineMedium),
          Text(
            'CITY RANK',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppPalette.smoke,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityQuest extends StatelessWidget {
  const _CommunityQuest();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      gradient: const LinearGradient(
        colors: [AppPalette.graphite, AppPalette.charcoal],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              const AppTag(
                label: '8,214 runners',
                color: AppPalette.electricBright,
              ),
              Text('84%', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Run around the world', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'One shared orbit. 33,674 km left.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppPalette.smoke,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadii.full),
            ),
            child: const LinearProgressIndicator(
              value: 0.84,
              minHeight: AppSpacing.sm,
              color: AppPalette.violet,
            ),
          ),
        ],
      ),
    );
  }
}
