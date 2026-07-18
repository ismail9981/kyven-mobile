import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/home_dashboard.dart';
import 'home_section_shell.dart';

class TrainingPlanPreviewSection extends StatelessWidget {
  const TrainingPlanPreviewSection({required this.plan, super.key});

  final TrainingPlanPreview plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return HomeDashboardSection(
      title: 'Training Plan',
      subtitle: 'Today’s suggested rhythm',
      child: AppCard(
        key: const ValueKey('home-training-card'),
        variant: AppCardVariant.interactive,
        onTap: () => context.goNamed(AppRoute.training.name),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            final icon = DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: colors.glassBorder),
              ),
              child: const SizedBox.square(
                dimension: 56,
                child: Icon(Icons.directions_run_rounded),
              ),
            );
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${plan.duration} · ${plan.intensity}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  plan.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      icon,
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: copy),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    key: const ValueKey('home-view-plan-button'),
                    label: 'View Plan',
                    onPressed: () => context.goNamed(AppRoute.training.name),
                    variant: AppButtonVariant.secondary,
                  ),
                ],
              );
            }

            return Row(
              children: [
                icon,
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: copy),
                const SizedBox(width: AppSpacing.md),
                AppButton(
                  key: const ValueKey('home-view-plan-button'),
                  label: 'View Plan',
                  onPressed: () => context.goNamed(AppRoute.training.name),
                  variant: AppButtonVariant.secondary,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
