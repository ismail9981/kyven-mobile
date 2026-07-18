import 'package:flutter/material.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTag(
                label: 'Monday · Muscat',
                color: AppPalette.electricBright,
                icon: Icons.wb_sunny_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Morning, Alex.', style: theme.textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'The road is yours.',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppPalette.smoke,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: AppLayout.avatarSmall,
          height: AppLayout.avatarSmall,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: AppKyvenSignature.velocityGradient,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const AppKyvenMark(color: AppPalette.white, size: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: AppSpacing.sm,
                  height: AppSpacing.sm,
                  decoration: const BoxDecoration(
                    color: AppPalette.electricBright,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WeeklyHero extends StatelessWidget {
  const WeeklyHero({required this.onStart, super.key});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      showShadow: true,
      glowColor: AppPalette.electricBright,
      padding: const EdgeInsets.all(AppSpacing.xl),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppPalette.electricCore,
          AppPalette.electricDeep,
          AppPalette.violetDeep,
        ],
      ),
      borderColor: AppPalette.electricBright,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < AppLayout.compactBreakpoint;
          final ring = AppProgressRing(
            progress: 0.74,
            size: AppLayout.heroRing,
            strokeWidth: AppSpacing.md,
            trackColor: AppPalette.white.withValues(alpha: 0.16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '18.4',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: AppPalette.white,
                  ),
                ),
                Text(
                  'KM THIS WEEK',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppPalette.cloud,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          );
          final copy = Column(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                '74% of your weekly goal',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppPalette.lime,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Keep the\nmomentum.',
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppPalette.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Start a run',
                icon: Icons.arrow_forward_rounded,
                onPressed: onStart,
              ),
            ],
          );
          if (compact) {
            return Column(
              children: [
                ring,
                const SizedBox(height: AppSpacing.xl),
                copy,
              ],
            );
          }
          return Row(
            children: [
              ring,
              const SizedBox(width: AppSpacing.xl),
              Expanded(child: copy),
            ],
          );
        },
      ),
    );
  }
}

class AnimatedStats extends StatelessWidget {
  const AnimatedStats({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _Stat(value: 3, suffix: '', label: 'Runs'),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _Stat(value: 102, suffix: 'm', label: 'Active'),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _Stat(value: 6, suffix: 'd', label: 'Streak'),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.suffix, required this.label});

  final String label;
  final String suffix;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: value),
        duration: const Duration(milliseconds: 700),
        builder: (context, value, child) => Column(
          children: [
            Text('$value$suffix', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppPalette.smoke,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
