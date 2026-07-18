import 'package:flutter/material.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        key: const PageStorageKey('profile-scroll'),
        child: AppResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AthleteHeader(),
              const SizedBox(height: AppSpacing.xl),
              const _FormHero(),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(
                title: 'Personal records',
                subtitle: 'The numbers that define your edge',
              ),
              const SizedBox(height: AppSpacing.md),
              const _RecordGrid(),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(
                title: 'Earned, never given',
                subtitle: 'Recent badges',
              ),
              const SizedBox(height: AppSpacing.md),
              const _BadgeRow(),
              const SizedBox(height: AppSpacing.xl),
              const _GoalCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AthleteHeader extends StatelessWidget {
  const _AthleteHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: AppLayout.avatarLarge,
          height: AppLayout.avatarLarge,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: AppKyvenSignature.velocityGradient,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const AppKyvenMark(color: AppPalette.white, size: 34),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  decoration: BoxDecoration(
                    color: AppPalette.lime,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppPalette.ink, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppTag(
                label: 'Athlete · Level 12',
                color: AppPalette.electricBright,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Alex Morgan', style: theme.textTheme.headlineMedium),
              Text(
                'Muscat · Running since 2021',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppPalette.smoke,
                ),
              ),
            ],
          ),
        ),
        AppIconButton(
          onPressed: () {},
          semanticLabel: 'Profile actions',
          icon: Icons.more_horiz_rounded,
        ),
      ],
    );
  }
}

class _FormHero extends StatelessWidget {
  const _FormHero();

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
        colors: [AppPalette.electricDeep, AppPalette.graphite],
      ),
      child: Row(
        children: [
          AppProgressRing(
            progress: 0.86,
            size: AppLayout.heroRing,
            strokeWidth: AppSpacing.md,
            trackColor: AppPalette.white.withValues(alpha: 0.14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('86', style: theme.textTheme.headlineLarge),
                Text(
                  'FORM',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppPalette.cloud,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You’re in a\nstrong phase.',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                const AppTag(
                  label: '6 day streak',
                  color: AppPalette.electricBright,
                  icon: Icons.local_fire_department_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordGrid extends StatelessWidget {
  const _RecordGrid();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _Record(
            value: '22:18',
            label: 'FASTEST 5K',
            color: AppPalette.electricBright,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Record(
            value: '48:42',
            label: 'FASTEST 10K',
            color: AppPalette.violet,
          ),
        ),
      ],
    );
  }
}

class _Record extends StatelessWidget {
  const _Record({
    required this.value,
    required this.label,
    required this.color,
  });
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: AppSpacing.xl, height: AppSpacing.xs, color: color),
          const SizedBox(height: AppSpacing.xl),
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppPalette.smoke,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badges = const [
      _BadgeSpec(
        icon: Icons.bolt_rounded,
        label: 'SPEED',
        title: 'Lightning medal',
        accent: AppPalette.warning,
      ),
      _BadgeSpec(
        icon: Icons.terrain_rounded,
        label: 'VERTICAL',
        title: 'Mountain badge',
        accent: AppPalette.cloud,
      ),
      _BadgeSpec(
        icon: Icons.nights_stay_rounded,
        label: 'NIGHT',
        title: 'Moon medal',
        accent: AppPalette.violet,
      ),
      _BadgeSpec(
        icon: Icons.route_rounded,
        label: '100 KM',
        title: 'Distance medal',
        accent: AppPalette.lime,
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final badge in badges)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Column(
                children: [
                  _AchievementBadge(spec: badge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    badge.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppPalette.smoke,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BadgeSpec {
  const _BadgeSpec({
    required this.icon,
    required this.label,
    required this.title,
    required this.accent,
  });

  final Color accent;
  final IconData icon;
  final String label;
  final String title;
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.spec});

  final _BadgeSpec spec;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: spec.title,
      child: Container(
        width: AppLayout.avatarLarge,
        height: AppLayout.avatarLarge + AppSpacing.sm,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.lg)),
          boxShadow: spec.accent == AppPalette.lime
              ? AppShadows.glow(spec.accent, opacity: 0.12)
              : AppShadows.low(Theme.of(context).brightness),
        ),
        child: CustomPaint(
          painter: _BadgePlatePainter(accent: spec.accent),
          child: Center(
            child: Icon(
              spec.icon,
              color: spec.accent,
              size: AppLayout.navigationCenterAction * 0.54,
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgePlatePainter extends CustomPainter {
  const _BadgePlatePainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final plate = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        AppSpacing.xs,
        AppSpacing.md,
        size.width - AppSpacing.sm,
        size.height - AppSpacing.lg,
      ),
      const Radius.circular(AppRadii.md),
    );
    final body = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppPalette.steel, AppPalette.graphite, AppPalette.charcoal],
      ).createShader(rect);
    final outline = Paint()
      ..color = accent.withValues(alpha: 0.46)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final engraving = Paint()
      ..color = AppPalette.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final notch = Path()
      ..moveTo(size.width * 0.34, AppSpacing.md)
      ..lineTo(size.width * 0.5, AppSpacing.xs)
      ..lineTo(size.width * 0.66, AppSpacing.md);

    canvas
      ..drawRRect(plate, body)
      ..drawRRect(plate, outline)
      ..drawPath(notch, outline)
      ..drawLine(
        Offset(size.width * 0.24, size.height * 0.72),
        Offset(size.width * 0.76, size.height * 0.72),
        engraving,
      )
      ..drawLine(
        Offset(size.width * 0.34, size.height * 0.82),
        Offset(size.width * 0.66, size.height * 0.82),
        engraving,
      );
  }

  @override
  bool shouldRepaint(covariant _BadgePlatePainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class _GoalCard extends StatelessWidget {
  const _GoalCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      color: AppPalette.lime,
      borderColor: AppPalette.lime,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT HORIZON',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppPalette.ink,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Half marathon\nunder 1:50.',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppPalette.ink,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.flag_rounded,
            size: AppLayout.iconContainer,
            color: AppPalette.ink,
          ),
        ],
      ),
    );
  }
}
