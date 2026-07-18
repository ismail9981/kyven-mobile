import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/home_dashboard.dart';
import 'home_section_shell.dart';

class ChallengesPreviewSection extends StatelessWidget {
  const ChallengesPreviewSection({required this.challenges, super.key});

  final List<ChallengePreview> challenges;

  @override
  Widget build(BuildContext context) {
    return HomeDashboardSection(
      title: 'Challenges',
      subtitle: 'Small pushes, not pressure',
      child: SizedBox(
        key: const ValueKey('home-challenges-carousel'),
        height: 154,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: challenges.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppSpacing.md),
          itemBuilder: (context, index) {
            return _ChallengeCard(challenge: challenges[index]);
          },
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final ChallengePreview challenge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return SizedBox(
      width: 228,
      child: AppCard(
        variant: AppCardVariant.elevated,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTag(
              label: '${(challenge.progress * 100).round()}%',
              color: AppPalette.electricBright,
              icon: Icons.flag_rounded,
            ),
            const Spacer(),
            Text(challenge.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              challenge.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
