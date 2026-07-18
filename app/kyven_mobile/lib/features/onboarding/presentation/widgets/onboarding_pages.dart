import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import 'onboarding_education_card.dart';
import 'onboarding_option_card.dart';
import 'onboarding_page_layout.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      semanticLabel: 'Welcome to KYVEN onboarding',
      eyebrow: 'KYVEN',
      title: 'Build your movement identity.',
      body:
          'A calm, premium running companion for consistency, progress, and momentum.',
      hero: Semantics(
        label: 'Motion Path introduction artwork',
        image: true,
        child: AppProgressRing(
          progress: 0.72,
          size: 184,
          strokeWidth: AppSpacing.md,
          child: const AppKyvenMark(size: 56, color: AppPalette.white),
        ),
      ),
    );
  }
}

class OnboardingWhyKyvenPage extends StatelessWidget {
  const OnboardingWhyKyvenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageLayout(
      semanticLabel: 'Why KYVEN onboarding step',
      eyebrow: 'Why KYVEN',
      title: 'Consistency becomes visible.',
      body: 'KYVEN keeps the experience focused, human, and easy to return to.',
      children: [
        OnboardingEducationCard(
          icon: Icons.calendar_today_rounded,
          title: 'Build consistency',
          description: 'Small runs compound into durable rhythm.',
        ),
        OnboardingEducationCard(
          icon: Icons.trending_up_rounded,
          title: 'Track progress',
          description: 'See improvement without drowning in metrics.',
        ),
        OnboardingEducationCard(
          icon: Icons.route_rounded,
          title: 'Create your Motion Path',
          description: 'Every run shapes a signature that is uniquely yours.',
        ),
      ],
    );
  }
}

class OnboardingGoalsPage extends StatelessWidget {
  const OnboardingGoalsPage({
    required this.selectedGoals,
    required this.onGoalToggled,
    super.key,
  });

  final ValueChanged<String> onGoalToggled;
  final Set<String> selectedGoals;

  @override
  Widget build(BuildContext context) {
    const goals = [
      ('lose-weight', 'Lose Weight', Icons.local_fire_department_rounded),
      ('run-faster', 'Run Faster', Icons.bolt_rounded),
      ('stay-active', 'Stay Active', Icons.directions_walk_rounded),
      ('build-habit', 'Build Habit', Icons.repeat_rounded),
      ('first-5k', 'Complete First 5K', Icons.flag_rounded),
    ];

    return OnboardingPageLayout(
      semanticLabel: 'Running goals onboarding step',
      eyebrow: 'Goals',
      title: 'Choose what moves you.',
      body: 'Select one or more. This only shapes the preview for now.',
      children: [
        for (final (id, title, icon) in goals)
          OnboardingOptionCard(
            key: ValueKey('onboarding-goal-$id'),
            title: title,
            description: _goalDescription(id),
            icon: icon,
            selected: selectedGoals.contains(id),
            selectedKey: ValueKey('onboarding-goal-$id-selected'),
            onTap: () => onGoalToggled(id),
          ),
      ],
    );
  }

  static String _goalDescription(String id) => switch (id) {
    'lose-weight' => 'Create steady movement without pressure.',
    'run-faster' => 'Build speed with focused training direction.',
    'stay-active' => 'Keep your week energized and balanced.',
    'build-habit' => 'Make running feel natural and repeatable.',
    _ => 'Move from first step to finish line with confidence.',
  };
}

class OnboardingActivityLevelPage extends StatelessWidget {
  const OnboardingActivityLevelPage({
    required this.selectedLevel,
    required this.onLevelSelected,
    super.key,
  });

  final ValueChanged<String> onLevelSelected;
  final String? selectedLevel;

  @override
  Widget build(BuildContext context) {
    const levels = [
      ('beginner', 'Beginner', 'I am starting or returning gently.'),
      ('intermediate', 'Intermediate', 'I run sometimes and want rhythm.'),
      ('advanced', 'Advanced', 'I train often and care about progress.'),
    ];

    return OnboardingPageLayout(
      semanticLabel: 'Activity level onboarding step',
      eyebrow: 'Activity Level',
      title: 'Meet KYVEN where you are.',
      body: 'No judgment. Just the right level of momentum.',
      children: [
        for (final (id, title, description) in levels)
          OnboardingOptionCard(
            key: ValueKey('onboarding-activity-$id'),
            title: title,
            description: description,
            icon: switch (id) {
              'beginner' => Icons.spa_rounded,
              'intermediate' => Icons.show_chart_rounded,
              _ => Icons.speed_rounded,
            },
            selected: selectedLevel == id,
            selectedKey: ValueKey('onboarding-activity-$id-selected'),
            onTap: () => onLevelSelected(id),
          ),
      ],
    );
  }
}

class OnboardingPermissionsEducationPage extends StatelessWidget {
  const OnboardingPermissionsEducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageLayout(
      semanticLabel: 'Permissions education onboarding step',
      eyebrow: 'Permissions',
      title: 'You stay in control.',
      body: 'KYVEN will ask only when the moment is useful and clear.',
      children: [
        OnboardingEducationCard(
          icon: Icons.location_on_rounded,
          title: 'Location',
          description: 'Used later to map distance, pace, and route accuracy.',
        ),
        OnboardingEducationCard(
          icon: Icons.directions_run_rounded,
          title: 'Motion & Fitness',
          description: 'Helps improve activity context when you allow it.',
        ),
        OnboardingEducationCard(
          icon: Icons.notifications_rounded,
          title: 'Notifications',
          description: 'Keeps training nudges quiet, useful, and optional.',
        ),
      ],
    );
  }
}

class OnboardingCompletionPage extends StatelessWidget {
  const OnboardingCompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      semanticLabel: 'Onboarding completion step',
      eyebrow: 'Ready',
      title: 'Your journey starts now.',
      body: 'Next, create an account or continue in the entry experience.',
      hero: Semantics(
        label: 'Completed Motion Path ring',
        image: true,
        child: AppProgressRing(
          progress: 1,
          size: 176,
          strokeWidth: AppSpacing.md,
          child: Icon(
            Icons.check_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
