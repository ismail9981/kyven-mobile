import 'package:flutter/material.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';

class OnboardingStepProgress extends StatelessWidget {
  const OnboardingStepProgress({
    required this.currentStep,
    required this.stepCount,
    super.key,
  });

  final int currentStep;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Semantics(
      label: 'Onboarding step ${currentStep + 1} of $stepCount',
      value: '${currentStep + 1} of $stepCount',
      child: Row(
        children: [
          for (var index = 0; index < stepCount; index++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: AppDurations.normal,
                curve: AppCurves.standard,
                height: AppSpacing.xs,
                decoration: BoxDecoration(
                  color: index <= currentStep
                      ? theme.colorScheme.primary
                      : colors.outline,
                  borderRadius: AppRadii.control,
                ),
              ),
            ),
            if (index != stepCount - 1) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
