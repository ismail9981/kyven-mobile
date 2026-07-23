import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/training_providers.dart';
import '../../domain/entities/training_plan.dart';
import '../widgets/training_formatters.dart';

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(trainingPlansProvider);
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        key: const PageStorageKey('training-scroll'),
        child: AppResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTag(
                label: 'Training Engine',
                color: colors.info,
                icon: Icons.route_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Structured plans.\nBuilt for motion.',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Choose a local plan and KYVEN will track your weekly rhythm on this device.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.secondaryText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              plans.when(
                data: (items) => _TrainingPlansList(plans: items),
                error: (_, _) => const AppErrorState(
                  title: 'Training unavailable',
                  message: 'KYVEN could not load training plans.',
                ),
                loading: () => const Center(
                  child: AppLoadingIndicator(label: 'Loading training plans'),
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

class _TrainingPlansList extends StatelessWidget {
  const _TrainingPlansList({required this.plans});

  final List<TrainingPlan> plans;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionHeader(
          title: 'Available Plans',
          subtitle: 'Built-in programs for the MVP',
        ),
        const SizedBox(height: AppSpacing.md),
        for (final plan in plans) ...[
          _TrainingPlanCard(plan: plan),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _TrainingPlanCard extends StatelessWidget {
  const _TrainingPlanCard({required this.plan});

  final TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppCard(
      key: ValueKey('training-plan-${plan.id}'),
      variant: AppCardVariant.interactive,
      semanticLabel: '${plan.title} training plan',
      onTap: () => context.goNamed(
        AppRoute.trainingDetail.name,
        pathParameters: {'planId': plan.id},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: AppTag(
              label: plan.difficulty.label,
              color: colors.highlight,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            plan.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.secondaryText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppTag(
                label: '${plan.durationWeeks} weeks',
                color: colors.info,
                icon: Icons.calendar_month_rounded,
              ),
              AppTag(
                label: plan.goal,
                color: colors.accent,
                icon: Icons.flag_rounded,
              ),
              AppTag(
                label: '${plan.sessionCount} sessions',
                color: colors.success,
                icon: Icons.check_circle_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            plan.primarySessionTypesLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
