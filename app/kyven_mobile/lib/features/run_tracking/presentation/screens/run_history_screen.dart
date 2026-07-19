import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/run_history_providers.dart';
import '../../domain/entities/run_statistics.dart';
import '../widgets/run_metric_formatters.dart';
import '../widgets/saved_run_card.dart';
import '../widgets/saved_run_formatters.dart';

class RunHistoryScreen extends ConsumerWidget {
  const RunHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(runHistoryProvider);
    final statistics = ref.watch(runStatisticsProvider);

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        key: const PageStorageKey('run-history-scroll'),
        child: AppResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HistoryHeader(onBack: () => context.goNamed(AppRoute.home.name)),
              const SizedBox(height: AppSpacing.xl),
              statistics.when(
                data: (stats) => _HistoryTotals(statistics: stats),
                loading: () => const AppLoadingIndicator(label: 'Loading runs'),
                error: (_, _) => const AppStatusBanner(
                  status: AppStatus.error,
                  title: 'History unavailable',
                  message: 'KYVEN could not load your run totals.',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              history.when(
                data: (runs) {
                  if (runs.isEmpty) {
                    return AppCard(
                      child: AppEmptyState(
                        title: 'No runs saved yet',
                        message:
                            'Your first completed run will shape your Motion Path.',
                        icon: Icons.route_rounded,
                        iconColor: AppPalette.electricBright,
                        actionLabel: 'Start Your First Run',
                        onAction: () => context.goNamed(AppRoute.run.name),
                      ),
                    );
                  }

                  return Column(
                    key: const ValueKey('run-history-list'),
                    children: [
                      for (var index = 0; index < runs.length; index++) ...[
                        SavedRunCard(
                          run: runs[index],
                          onTap: () => context.goNamed(
                            AppRoute.runDetail.name,
                            pathParameters: {'runId': runs[index].id},
                          ),
                        ),
                        if (index != runs.length - 1)
                          const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  );
                },
                loading: () => const AppLoadingIndicator(label: 'Loading runs'),
                error: (_, _) => const AppStatusBanner(
                  status: AppStatus.error,
                  title: 'History unavailable',
                  message: 'KYVEN could not load your saved runs.',
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconButton(
          onPressed: onBack,
          semanticLabel: 'Return home',
          icon: Icons.arrow_back_rounded,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Semantics(
            header: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Run History',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Every finished run, saved on this device.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryTotals extends StatelessWidget {
  const _HistoryTotals({required this.statistics});

  final RunStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${statistics.totalRuns} total runs, '
          '${statistics.totalDistanceKm.toStringAsFixed(1)} kilometers, '
          '${statistics.totalDuration.timeLabel} total time.',
      child: AppCard(
        variant: AppCardVariant.elevated,
        glowColor: AppPalette.electricBright,
        child: Row(
          children: [
            Expanded(
              child: AppMetric(
                value: '${statistics.totalRuns}',
                label: 'Total Runs',
              ),
            ),
            Expanded(
              child: AppMetric(
                value: kilometersLabel(statistics.totalDistanceKm),
                label: 'Distance',
              ),
            ),
            Expanded(
              child: AppMetric(
                value: statistics.totalDuration.timeLabel,
                label: 'Time',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
