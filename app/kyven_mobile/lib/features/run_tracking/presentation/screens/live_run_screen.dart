import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/location_tracking_providers.dart';
import '../../application/run_location_state.dart';
import '../../application/run_session_providers.dart';
import '../../domain/entities/run_session.dart';
import '../map/run_map.dart';
import '../widgets/live_run_widgets.dart';
import '../widgets/run_metric_formatters.dart';

class LiveRunScreen extends ConsumerWidget {
  const LiveRunScreen({super.key});

  Future<void> _confirmFinish(BuildContext context, WidgetRef ref) async {
    ref.read(runSessionProvider.notifier).requestFinish();
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: 'Finish run?',
      barrierDismissible: false,
      content: const Text('End this run session and view summary?'),
      actions: [
        TextButton(
          key: const ValueKey('run-finish-cancel-button'),
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const ValueKey('run-finish-confirm-button'),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
          child: const Text('Finish'),
        ),
      ],
    );

    if (!context.mounted) return;
    final notifier = ref.read(runSessionProvider.notifier);
    if (confirmed ?? false) {
      unawaited(ref.read(runLocationProvider.notifier).stopTracking());
      notifier.completeFinish();
      context.goNamed(AppRoute.runSummary.name);
    } else {
      notifier.cancelFinish();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(runSessionProvider);
    final locationState = ref.watch(runLocationProvider);
    final metrics = state.metrics;
    final theme = Theme.of(context);
    final isPaused = state.status == RunSessionStatus.paused;

    if (!state.hasActiveSession) {
      return NoActiveRun(
        message: 'No active run session.',
        onPrepare: () => context.goNamed(AppRoute.run.name),
      );
    }

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        key: const PageStorageKey('live-run-scroll'),
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
                  AppTag(
                    label: isPaused
                        ? 'Paused · ${locationState.gpsLabel}'
                        : locationState.gpsLabel,
                    color: _gpsColor(context, locationState),
                    icon: _gpsIcon(locationState),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIconButton(
                        onPressed: () {},
                        semanticLabel: 'Screen lock',
                        icon: Icons.lock_outline_rounded,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppIconButton(
                        onPressed: () {},
                        semanticLabel: 'Run settings',
                        icon: Icons.tune_rounded,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                height: 310,
                child: RunMap(locationState: locationState),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                isPaused ? 'Paused' : 'Running',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isPaused
                      ? context.appColors.warning
                      : context.appColors.primaryText,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'RUN//LIVE',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppPalette.smoke,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppProgressRing(
                progress: (metrics.distanceKm / 5).clamp(0.04, 1).toDouble(),
                size: AppLayout.runRing * 0.82,
                strokeWidth: AppSpacing.md,
                glowOpacity: isPaused ? 0.42 : 0.68,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label:
                          'Current pace ${metrics.currentPace.paceLabel} per kilometer',
                      child: ExcludeSemantics(
                        child: Text(
                          metrics.currentPace.paceLabel,
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: AppPalette.white,
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
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
              const SizedBox(height: AppSpacing.xl),
              LiveRunMetricsGrid(metrics: metrics),
              const SizedBox(height: AppSpacing.xl),
              LiveBioSignalCard(
                heartRate: metrics.heartRate,
                cadence: metrics.cadence,
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  LiveRunControl(
                    key: const ValueKey('run-finish-button'),
                    label: 'Finish',
                    icon: Icons.stop_rounded,
                    color: context.appColors.danger,
                    onTap: () => _confirmFinish(context, ref),
                  ),
                  LiveRunControl(
                    key: ValueKey(
                      isPaused ? 'run-resume-button' : 'run-pause-button',
                    ),
                    label: isPaused ? 'Resume' : 'Pause',
                    icon: isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    color: context.appColors.accent,
                    primary: true,
                    onTap: isPaused
                        ? ref.read(runSessionProvider.notifier).resume
                        : ref.read(runSessionProvider.notifier).pause,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Color _gpsColor(BuildContext context, RunLocationState locationState) {
    return switch (locationState.signalStatus) {
      LocationSignalStatus.ready => AppPalette.lime,
      LocationSignalStatus.weak => context.appColors.warning,
      LocationSignalStatus.searching => context.appColors.info,
      LocationSignalStatus.unavailable => context.appColors.error,
    };
  }

  IconData _gpsIcon(RunLocationState locationState) {
    return switch (locationState.signalStatus) {
      LocationSignalStatus.ready => Icons.gps_fixed_rounded,
      LocationSignalStatus.weak => Icons.gps_not_fixed_rounded,
      LocationSignalStatus.searching => Icons.gps_not_fixed_rounded,
      LocationSignalStatus.unavailable => Icons.gps_off_rounded,
    };
  }
}
