import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_durations.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/widgets.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.navigationShell.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
      value: 1,
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = Tween(begin: 0.7, end: 1.0).animate(curve);
    _scale = Tween(begin: 0.985, end: 1.0).animate(curve);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.navigationShell.currentIndex;
    if (next != _index) {
      _index = next;
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(scale: _scale, child: widget.navigationShell),
      ),
      bottomNavigationBar: _FloatingNavigation(
        currentIndex: widget.navigationShell.currentIndex,
        onSelected: _select,
      ),
    );
  }
}

class _FloatingNavigation extends StatelessWidget {
  const _FloatingNavigation({
    required this.currentIndex,
    required this.onSelected,
  });

  static const _items = [
    ('Home', Icons.home_rounded),
    ('Training', Icons.bolt_rounded),
    ('Start Run', Icons.directions_run_rounded),
    ('Challenges', Icons.emoji_events_rounded),
    ('Profile', Icons.person_rounded),
  ];

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.full)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: AppLayout.navigationFloatingHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppPalette.graphite.withValues(alpha: 0.58),
                  AppPalette.charcoal.withValues(alpha: 0.78),
                ],
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadii.full),
              ),
              border: Border.all(
                color: AppPalette.white.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.black.withValues(alpha: 0.34),
                  blurRadius: AppSpacing.xxl,
                  offset: const Offset(0, AppSpacing.sm),
                ),
                BoxShadow(
                  color: AppPalette.white.withValues(alpha: 0.06),
                  blurRadius: AppSpacing.lg,
                  offset: const Offset(0, -AppSpacing.xxs),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var index = 0; index < _items.length; index++)
                  Expanded(
                    child: _NavItem(
                      label: _items[index].$1,
                      icon: _items[index].$2,
                      selected: index == currentIndex,
                      primary: index == 2,
                      onTap: () => onSelected(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? AppPalette.white : AppPalette.smoke;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AppPressedScale(
        key: ValueKey('navigation-$label'),
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.full)),
        child: Center(
          child: AnimatedContainer(
            duration: AppDurations.fast,
            curve: Curves.easeOutCubic,
            width: primary ? AppLayout.navigationCenterAction : double.infinity,
            height: primary ? AppLayout.navigationCenterAction : null,
            padding: primary
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
            decoration: BoxDecoration(
              gradient: primary
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppPalette.electricBright,
                        AppPalette.electric,
                        AppPalette.lime,
                      ],
                      stops: [0, 0.58, 1],
                    )
                  : null,
              color: !primary && selected
                  ? AppPalette.white.withValues(alpha: 0.08)
                  : null,
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadii.full),
              ),
              border: primary
                  ? Border.all(color: AppPalette.white.withValues(alpha: 0.5))
                  : null,
              boxShadow: primary
                  ? [
                      BoxShadow(
                        color: AppPalette.electric.withValues(alpha: 0.22),
                        blurRadius: AppSpacing.xl,
                        spreadRadius: -AppSpacing.sm,
                      ),
                      BoxShadow(
                        color: AppPalette.black.withValues(alpha: 0.28),
                        blurRadius: AppSpacing.lg,
                        offset: const Offset(0, AppSpacing.xs),
                      ),
                    ]
                  : null,
            ),
            child: primary
                ? AnimatedScale(
                    scale: selected && !reduceMotion ? 1.06 : 1,
                    duration: AppDurations.fast,
                    curve: AppCurves.standard,
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppPalette.ink,
                      size: AppLayout.navigationIconSize + AppSpacing.sm,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: selected && !reduceMotion ? 1.08 : 1,
                        duration: AppDurations.fast,
                        curve: AppCurves.standard,
                        child: Icon(
                          icon,
                          color: color,
                          size: AppLayout.navigationIconSize,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AnimatedContainer(
                        duration: AppDurations.fast,
                        curve: AppCurves.standard,
                        width: selected ? AppSpacing.lg : AppSpacing.xs,
                        height: AppSpacing.xxs,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppPalette.electricBright
                              : AppPalette.transparent,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(AppRadii.full),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
