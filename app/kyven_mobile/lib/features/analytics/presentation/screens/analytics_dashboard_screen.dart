import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/analytics_providers.dart';
import '../../domain/entities/analytics_comparison.dart';
import '../../domain/entities/analytics_period.dart';
import '../../domain/entities/analytics_snapshot.dart';
import '../widgets/analytics_bar_chart.dart';
import '../widgets/analytics_formatters.dart';
import '../widgets/analytics_pace_chart.dart';
import '../widgets/analytics_summary_card.dart';
import '../widgets/personal_records_section.dart';
import '../widgets/training_load_card.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(analyticsSnapshotProvider);

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: AppResponsiveContent(
        child: snapshot.when(
          data: (data) => _AnalyticsContent(snapshot: data),
          loading: () => const Center(child: AppLoadingIndicator()),
          error: (error, stackTrace) => AppErrorState(
            title: 'Analytics unavailable',
            message: 'Your movement insights could not be loaded.',
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(analyticsSnapshotProvider),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsContent extends ConsumerWidget {
  const _AnalyticsContent({required this.snapshot});

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedAnalyticsPeriodProvider);
    final summary = selected == AnalyticsPeriodType.month
        ? snapshot.currentMonth
        : snapshot.currentWeek;
    final comparison = selected == AnalyticsPeriodType.month
        ? snapshot.monthlyComparison
        : snapshot.weeklyComparison;
    final distanceTrend = selected == AnalyticsPeriodType.month
        ? snapshot.monthlyDistanceTrend
        : snapshot.weeklyDistanceTrend;

    if (!snapshot.hasRuns) {
      return const _AnalyticsEmptyState();
    }

    return CustomScrollView(
      key: const ValueKey('analytics-dashboard'),
      slivers: [
        SliverToBoxAdapter(
          child: AppEntrance(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your movement history, shaped into signals.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.appColors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  key: const ValueKey('analytics-goals-button'),
                  label: 'Personal Goals',
                  onPressed: () => context.goNamed(AppRoute.goals.name),
                  variant: AppButtonVariant.secondary,
                  icon: Icons.flag_rounded,
                ),
                const SizedBox(height: AppSpacing.xl),
                _PeriodSelector(selected: selected),
              ],
            ),
          ),
        ),
        SliverList.list(
          children: [
            const SizedBox(height: AppSpacing.xl),
            AppEntrance(
              child: AnalyticsSummaryCard(
                summary: summary,
                comparison: comparison,
                title: selected == AnalyticsPeriodType.month
                    ? 'Current Month'
                    : 'Current Week',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _TrendCard(
              title: selected == AnalyticsPeriodType.month
                  ? 'Monthly Distance'
                  : 'Weekly Distance',
              subtitle: selected == AnalyticsPeriodType.month
                  ? 'Grouped into month-based weekly buckets.'
                  : 'Monday through Sunday, including zero days.',
              child: AnalyticsBarChart(
                key: const ValueKey('analytics-distance-chart'),
                trend: distanceTrend,
                semanticLabel: 'Distance trend chart',
                valueSuffix: ' km',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _TrendCard(
              title: 'Pace Trend',
              subtitle: 'Latest valid timed runs in chronological order.',
              child: AnalyticsPaceChart(
                key: const ValueKey('analytics-pace-chart'),
                trend: snapshot.paceTrend,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TrainingLoadCard(load: snapshot.trainingLoad),
            const SizedBox(height: AppSpacing.xl),
            _ComparisonCard(comparison: comparison),
            const SizedBox(height: AppSpacing.xl),
            PersonalRecordsSection(records: snapshot.personalRecords),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ],
    );
  }
}

class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector({required this.selected});

  final AnalyticsPeriodType selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: 'Analytics period selector',
      child: Wrap(
        spacing: AppSpacing.sm,
        children: [
          _PeriodButton(
            label: 'Week',
            selected: selected == AnalyticsPeriodType.week,
            onTap: () => ref
                .read(selectedAnalyticsPeriodProvider.notifier)
                .select(AnalyticsPeriodType.week),
          ),
          _PeriodButton(
            label: 'Month',
            selected: selected == AnalyticsPeriodType.month,
            onTap: () => ref
                .read(selectedAnalyticsPeriodProvider.notifier)
                .select(AnalyticsPeriodType.month),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onTap,
      variant: selected ? AppButtonVariant.primary : AppButtonVariant.secondary,
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final Widget child;
  final String subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.comparison});

  final AnalyticsComparison comparison;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      key: const ValueKey('analytics-comparison-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compared with Previous Period',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              AppMetric(
                value: AnalyticsFormatters.change(
                  comparison.distanceChangePercent,
                  improvementMode: false,
                ),
                label: 'Distance',
              ),
              AppMetric(
                value: AnalyticsFormatters.change(
                  comparison.durationChangePercent,
                  improvementMode: false,
                ),
                label: 'Duration',
              ),
              AppMetric(
                value: AnalyticsFormatters.change(
                  comparison.runCountChangePercent,
                  improvementMode: false,
                ),
                label: 'Runs',
              ),
              AppMetric(
                value: AnalyticsFormatters.change(
                  comparison.paceImprovementPercent,
                  improvementMode: true,
                ),
                label: 'Pace',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsEmptyState extends StatelessWidget {
  const _AnalyticsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppCard(
        key: ValueKey('analytics-empty-state'),
        child: AppEmptyState(
          title: 'No analytics yet',
          message: 'Complete your first run to reveal your movement patterns.',
          icon: Icons.query_stats_rounded,
        ),
      ),
    );
  }
}
