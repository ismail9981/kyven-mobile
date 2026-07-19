import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/run_session_providers.dart';
import '../widgets/run_metric_formatters.dart';

class RunSummaryScreen extends ConsumerWidget {
  const RunSummaryScreen({super.key});

  void _done(BuildContext context, WidgetRef ref) {
    ref.read(runSessionProvider.notifier).reset();
    context.goNamed(AppRoute.home.name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(runSessionProvider).summary;
    final theme = Theme.of(context);

    if (summary == null) {
      return AppScaffold(
        body: Center(
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No completed run yet.',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Prepare Run',
                  onPressed: () => context.goNamed(AppRoute.run.name),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final metrics = summary.metrics;
    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        key: const PageStorageKey('run-summary-scroll'),
        child: AppResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Great run.',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You kept moving.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppPalette.smoke,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppProgressRing(
                progress: 1,
                size: AppLayout.runRing * 0.86,
                strokeWidth: AppSpacing.md,
                glowOpacity: 0.7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      metrics.distanceKm.distanceLabel,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: AppPalette.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'KILOMETERS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppPalette.smoke,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                key: const ValueKey('run-summary-metrics-card'),
                variant: AppCardVariant.elevated,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppMetric(
                            value: metrics.elapsed.timeLabel,
                            label: 'Duration',
                          ),
                        ),
                        Expanded(
                          child: AppMetric(
                            value: metrics.averagePace.paceLabel,
                            label: 'Avg Pace /km',
                          ),
                        ),
                        Expanded(
                          child: AppMetric(
                            value: '${metrics.calories}',
                            label: 'Calories',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: AppMetric(
                            value: '${metrics.cadence}',
                            label: 'Cadence SPM',
                          ),
                        ),
                        Expanded(
                          child: AppMetric(
                            value: '${metrics.heartRate}',
                            label: 'Avg Heart Rate BPM',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _RoutePreviewCard(),
              if (summary.achievement.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                AppStatusBanner(
                  status: AppStatus.success,
                  title: summary.achievement,
                  message: 'Your first KYVEN run is complete.',
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                key: const ValueKey('run-summary-done-button'),
                label: 'Done',
                onPressed: () => _done(context, ref),
                icon: Icons.check_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                key: const ValueKey('run-summary-share-button'),
                label: 'Share Run',
                onPressed: () {},
                variant: AppButtonVariant.secondary,
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutePreviewCard extends StatelessWidget {
  const _RoutePreviewCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      semanticLabel: 'Route preview',
      child: SizedBox(
        height: 144,
        child: Stack(
          children: [
            const Positioned.fill(child: AppKyvenCardMark()),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.route_rounded,
                    color: theme.colorScheme.primary,
                    size: 34,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Route preview', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
