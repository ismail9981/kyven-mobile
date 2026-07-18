import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';

class StartRunScreen extends StatefulWidget {
  const StartRunScreen({super.key});

  @override
  State<StartRunScreen> createState() => _StartRunScreenState();
}

class _StartRunScreenState extends State<StartRunScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: AppDurations.slow);
    unawaited(_pulse.repeat(reverse: true));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _previewAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action is visual-only in this preview.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        key: const PageStorageKey('start-run-scroll'),
        child: AppResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  const AppTag(
                    label: 'GPS locked · Preview',
                    color: AppPalette.lime,
                    icon: Icons.gps_fixed_rounded,
                  ),
                  AppIconButton(
                    onPressed: () => _previewAction('Run settings'),
                    semanticLabel: 'Run settings',
                    icon: Icons.tune_rounded,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'RUN//LIVE',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppPalette.smoke,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.maxWidth < AppLayout.runRing
                      ? constraints.maxWidth
                      : AppLayout.runRing;
                  return Center(
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) => Transform.scale(
                        scale: 0.99 + (_pulse.value * 0.01),
                        child: child,
                      ),
                      child: AppProgressRing(
                        progress: 0.78,
                        size: size,
                        strokeWidth: AppSpacing.md,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '5:24',
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: AppPalette.white,
                                fontSize: 72,
                              ),
                            ),
                            Text(
                              'CURRENT PACE /KM',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppPalette.smoke,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const _RunMetrics(),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                gradient: const LinearGradient(
                  colors: [AppPalette.graphite, AppPalette.charcoal],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: context.appColors.danger,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('142 BPM', style: theme.textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'STEADY · AEROBIC ZONE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppPalette.smoke,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppProgressRing(
                      progress: 0.64,
                      size: AppLayout.badgeSize,
                      strokeWidth: AppSpacing.xs,
                      child: Text('Z3', style: theme.textTheme.labelLarge),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  _RunControl(
                    label: 'Finish',
                    icon: Icons.stop_rounded,
                    color: context.appColors.danger,
                    onTap: () => _previewAction('Finish run'),
                  ),
                  _RunControl(
                    label: 'Pause',
                    icon: Icons.pause_rounded,
                    color: context.appColors.accent,
                    primary: true,
                    onTap: () => _previewAction('Pause run'),
                  ),
                  _RunControl(
                    label: 'Lock',
                    icon: Icons.lock_outline_rounded,
                    color: AppPalette.electricBright,
                    onTap: () => _previewAction('Screen lock'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunMetrics extends StatelessWidget {
  const _RunMetrics();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: AppMetric(value: '6.82', label: 'Kilometers'),
        ),
        Expanded(
          child: AppMetric(value: '36:51', label: 'Time'),
        ),
        Expanded(
          child: AppMetric(value: '486', label: 'Calories'),
        ),
      ],
    );
  }
}

class _RunControl extends StatelessWidget {
  const _RunControl({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.primary = false,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = primary
        ? AppLayout.avatarLarge
        : AppLayout.navigationCenterAction;
    return Semantics(
      button: true,
      label: label,
      child: Column(
        children: [
          AppPressedScale(
            onTap: onTap,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadii.full),
            ),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary ? color : color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.5)),
                boxShadow: primary
                    ? AppShadows.glow(color, opacity: 0.28)
                    : AppShadows.low(Theme.of(context).brightness),
              ),
              child: Icon(
                icon,
                color: primary ? AppPalette.ink : color,
                size: primary ? AppLayout.iconContainer : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
