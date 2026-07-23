import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/training_providers.dart';
import '../../domain/entities/training_day.dart';
import '../../domain/entities/training_plan.dart';
import '../../domain/entities/training_progress.dart';
import '../../domain/entities/training_session.dart';
import '../widgets/training_formatters.dart';

class TrainingPlanDetailScreen extends ConsumerWidget {
  const TrainingPlanDetailScreen({required this.planId, super.key});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planValue = ref.watch(trainingPlanProvider(planId));
    final progressValue = ref.watch(trainingProgressProvider(planId));

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: planValue.when(
        data: (plan) {
          if (plan == null) {
            return const Center(
              child: AppErrorState(
                title: 'Plan not found',
                message: 'This training plan is not available.',
              ),
            );
          }

          return progressValue.when(
            data: (progress) => _TrainingPlanDetailContent(
              plan: plan,
              progress: progress,
              onCompleteToday: (day) async {
                await ref
                    .read(trainingProgressActionsProvider)
                    .completeSession(plan: plan, progress: progress, day: day);
              },
            ),
            error: (_, _) => const Center(
              child: AppErrorState(
                title: 'Progress unavailable',
                message: 'KYVEN could not load this plan’s progress.',
              ),
            ),
            loading: () => const Center(
              child: AppLoadingIndicator(label: 'Loading progress'),
            ),
          );
        },
        error: (_, _) => const Center(
          child: AppErrorState(
            title: 'Plan unavailable',
            message: 'KYVEN could not load this training plan.',
          ),
        ),
        loading: () => const Center(
          child: AppLoadingIndicator(label: 'Loading training plan'),
        ),
      ),
    );
  }
}

class _TrainingPlanDetailContent extends StatelessWidget {
  const _TrainingPlanDetailContent({
    required this.plan,
    required this.progress,
    required this.onCompleteToday,
  });

  final Future<void> Function(TrainingDay day) onCompleteToday;
  final TrainingPlan plan;
  final TrainingProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final currentDay = _currentTrainingDay;

    return SingleChildScrollView(
      key: PageStorageKey('training-plan-${plan.id}-scroll'),
      child: AppResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                label: 'Plans',
                icon: Icons.arrow_back_rounded,
                onPressed: () => context.pop(),
                variant: AppButtonVariant.ghost,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(plan.title, style: theme.textTheme.displaySmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              plan.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.secondaryText,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _ProgressCard(plan: plan, progress: progress),
            const SizedBox(height: AppSpacing.xl),
            if (currentDay != null)
              _TodaySessionCard(
                day: currentDay,
                completed: progress.isCompleted(currentDay.sessionKey),
                onComplete: () => onCompleteToday(currentDay),
              ),
            const SizedBox(height: AppSpacing.xl),
            const AppSectionHeader(
              title: 'Plan Details',
              subtitle: 'Week-by-week structure',
            ),
            const SizedBox(height: AppSpacing.md),
            for (var week = 1; week <= plan.durationWeeks; week += 1) ...[
              _WeekCard(
                weekNumber: week,
                days: plan.daysForWeek(week),
                progress: progress,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  TrainingDay? get _currentTrainingDay {
    for (final day in plan.days) {
      if (day.weekNumber == progress.currentWeek &&
          day.dayNumber == progress.currentDay) {
        return day;
      }
    }
    return plan.days.isEmpty ? null : plan.days.last;
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.plan, required this.progress});

  final TrainingPlan plan;
  final TrainingProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final percent = (progress.completionPercentage * 100).round();

    return AppCard(
      key: const ValueKey('training-progress-card'),
      variant: AppCardVariant.elevated,
      glowColor: colors.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Progress',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text('$percent%', style: theme.textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.full),
            child: LinearProgressIndicator(
              minHeight: AppSpacing.sm,
              value: progress.completionPercentage,
              backgroundColor: colors.outline,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppMetric(
                  value: '${progress.completedSessions.length}',
                  label: 'Completed Sessions',
                ),
              ),
              Expanded(
                child: AppMetric(
                  value: '${progress.currentWeek}',
                  label: 'Current Week',
                ),
              ),
              Expanded(
                child: AppMetric(
                  value: '${progress.currentDay}',
                  label: 'Current Day',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${plan.sessionCount} total sessions · ${plan.durationWeeks} weeks',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySessionCard extends StatelessWidget {
  const _TodaySessionCard({
    required this.day,
    required this.completed,
    required this.onComplete,
  });

  final bool completed;
  final TrainingDay day;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppCard(
      key: const ValueKey('training-today-session-card'),
      showShadow: true,
      borderColor: completed ? colors.success : colors.outline,
      glowColor: completed ? colors.success : colors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTag(
            label: completed ? 'Completed' : 'Today',
            color: completed ? colors.success : colors.accent,
            icon: completed
                ? Icons.check_circle_rounded
                : Icons.play_arrow_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(day.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            day.session.notes,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.secondaryText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SessionMeta(session: day.session),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            key: const ValueKey('training-complete-session-button'),
            label: completed ? 'Session Complete' : 'Mark Complete',
            icon: completed
                ? Icons.check_rounded
                : Icons.check_circle_outline_rounded,
            onPressed: completed ? null : onComplete,
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.weekNumber,
    required this.days,
    required this.progress,
  });

  final List<TrainingDay> days;
  final TrainingProgress progress;
  final int weekNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      key: ValueKey('training-week-$weekNumber'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Week $weekNumber', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          for (final day in days)
            _TrainingDayTile(day: day, progress: progress),
        ],
      ),
    );
  }
}

class _TrainingDayTile extends StatelessWidget {
  const _TrainingDayTile({required this.day, required this.progress});

  final TrainingDay day;
  final TrainingProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final completed = progress.isCompleted(day.sessionKey);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: completed ? colors.success : colors.secondaryText,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${day.dayNumber} · ${day.title}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  day.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SessionMeta(session: day.session),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionMeta extends StatelessWidget {
  const _SessionMeta({required this.session});

  final TrainingSession session;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        AppTag(label: session.type.label, color: colors.info),
        AppTag(label: session.distanceLabel, color: colors.highlight),
        AppTag(
          label: session.estimatedDuration.trainingDurationLabel,
          color: colors.warning,
        ),
        if (session.targetPace case final pace?)
          AppTag(label: pace.trainingPaceLabel, color: colors.accent),
      ],
    );
  }
}
