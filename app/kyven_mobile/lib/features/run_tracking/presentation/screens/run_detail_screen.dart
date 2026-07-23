import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/run_history_providers.dart';
import '../../domain/entities/saved_run.dart';
import '../../domain/services/session_name_generator.dart';
import '../map/saved_run_route_map.dart';
import '../widgets/run_metric_formatters.dart';
import '../widgets/saved_run_formatters.dart';

class RunDetailScreen extends ConsumerStatefulWidget {
  const RunDetailScreen({required this.runId, super.key});

  final String runId;

  @override
  ConsumerState<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends ConsumerState<RunDetailScreen> {
  Object? _deleteError;
  var _isDeleting = false;

  Future<void> _confirmDelete(SavedRun run) async {
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: 'Delete run?',
      content: const Text(
        'This removes the saved run from this device and updates your local totals.',
      ),
      actions: [
        TextButton(
          key: const ValueKey('run-delete-cancel-button'),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const ValueKey('run-delete-confirm-button'),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete Run'),
        ),
      ],
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _deleteError = null;
      _isDeleting = true;
    });
    try {
      await ref.read(runHistoryRepositoryProvider).deleteRun(run.id);
      if (mounted) {
        context.goNamed(AppRoute.runHistory.name);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _deleteError = error);
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(selectedSavedRunProvider(widget.runId));
    final theme = Theme.of(context);

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: run.when(
        data: (savedRun) {
          if (savedRun == null) {
            return AppResponsiveContent(
              child: Center(
                child: AppCard(
                  child: AppEmptyState(
                    title: 'Run not found',
                    message:
                        'This run may have been deleted from local history.',
                    icon: Icons.route_rounded,
                    actionLabel: 'Back to History',
                    onAction: () => context.goNamed(AppRoute.runHistory.name),
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            key: const PageStorageKey('run-detail-scroll'),
            child: AppResponsiveContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AppIconButton(
                        onPressed: () =>
                            context.goNamed(AppRoute.runHistory.name),
                        semanticLabel: 'Back to run history',
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
                                const SessionNameGenerator().generate(savedRun),
                                style: theme.textTheme.headlineMedium,
                              ),
                              Text(
                                '${detailedDateLabel(savedRun.completedAt)} · ${savedRun.timeLabel}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: context.appColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _RunDetailHero(run: savedRun),
                  const SizedBox(height: AppSpacing.xl),
                  _MetricPanel(run: savedRun),
                  if (savedRun.hasRoute) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _RoutePreview(run: savedRun),
                  ],
                  if (savedRun.achievement.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppStatusBanner(
                      status: AppStatus.success,
                      title: savedRun.achievement,
                      message:
                          'This achievement is part of your Motion Path record.',
                    ),
                  ],
                  if (_deleteError != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const AppStatusBanner(
                      status: AppStatus.error,
                      title: 'Run not deleted',
                      message: 'KYVEN could not delete this run. Try again.',
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    key: const ValueKey('run-detail-share-button'),
                    label: 'Share Run',
                    onPressed: () {},
                    variant: AppButtonVariant.secondary,
                    icon: Icons.ios_share_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    key: const ValueKey('run-detail-delete-button'),
                    label: 'Delete Run',
                    isLoading: _isDeleting,
                    onPressed: _isDeleting
                        ? null
                        : () => _confirmDelete(savedRun),
                    variant: AppButtonVariant.destructive,
                    icon: Icons.delete_outline_rounded,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(label: 'Loading run details'),
        ),
        error: (_, _) => AppResponsiveContent(
          child: Center(
            child: AppStatusBanner(
              status: AppStatus.error,
              title: 'Run unavailable',
              message: 'KYVEN could not load this run.',
            ),
          ),
        ),
      ),
    );
  }
}

class _RunDetailHero extends StatelessWidget {
  const _RunDetailHero({required this.run});

  final SavedRun run;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      variant: AppCardVariant.elevated,
      glowColor: AppPalette.electricBright,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppPalette.electricCore,
          AppPalette.electricDeep,
          AppPalette.violetDeep,
        ],
      ),
      child: Row(
        children: [
          AppProgressRing(
            progress: 1,
            size: AppLayout.heroRing * 0.72,
            strokeWidth: AppSpacing.sm,
            trackColor: AppPalette.white.withValues(alpha: 0.14),
            glowOpacity: 0.58,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  kilometersLabel(run.distanceKm),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppPalette.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'DISTANCE',
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
                  'Motion saved.',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppPalette.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'A clean record of this run now shapes your local KYVEN profile.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppPalette.cloud,
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

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({required this.run});

  final SavedRun run;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppMetric(value: run.duration.timeLabel, label: 'Time'),
              ),
              Expanded(
                child: AppMetric(
                  value: run.averagePace.paceLabel,
                  label: 'Avg Pace',
                ),
              ),
              Expanded(
                child: AppMetric(value: '${run.calories}', label: 'Calories'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppMetric(value: '${run.cadence}', label: 'Cadence'),
              ),
              Expanded(
                child: AppMetric(
                  value: '${run.averageHeartRate}',
                  label: 'Avg HR',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutePreview extends StatelessWidget {
  const _RoutePreview({required this.run});

  final SavedRun run;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      semanticLabel: 'Route preview',
      child: SizedBox(
        key: const ValueKey('run-detail-route-map-section'),
        height: 240,
        child: SavedRunRouteMap(route: run.route),
      ),
    );
  }
}
