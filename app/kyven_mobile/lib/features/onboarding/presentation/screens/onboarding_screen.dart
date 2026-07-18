import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/onboarding_pages.dart';
import '../widgets/onboarding_step_progress.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 6;

  final _pageController = PageController();
  final _selectedGoals = <String>{};
  String? _activityLevel;
  var _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _advance() {
    if (_currentPage == _pageCount - 1) {
      _continueToAuthentication();
      return;
    }

    unawaited(
      _pageController.nextPage(
        duration: AppDurations.normal,
        curve: AppCurves.emphasized,
      ),
    );
  }

  void _continueToAuthentication() {
    context.goNamed(AppRoute.authentication.name);
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (!_selectedGoals.add(goal)) {
        _selectedGoals.remove(goal);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFirstPage = _currentPage == 0;
    final isLastPage = _currentPage == _pageCount - 1;
    final showTopSkip = !isFirstPage && !isLastPage;
    final primaryLabel = switch (_currentPage) {
      0 => 'Get Started',
      4 || 5 => 'Continue',
      _ => 'Continue',
    };

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: Stack(
        children: [
          const Positioned.fill(child: AppKyvenVelocityField(intensity: 0.55)),
          Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.md,
                    AppSpacing.page,
                    AppSpacing.none,
                  ),
                  child: Visibility(
                    visible: showTopSkip,
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    child: AnimatedOpacity(
                      opacity: showTopSkip ? 1 : 0,
                      duration: AppDurations.fast,
                      child: AppButton(
                        key: const ValueKey('onboarding-skip-button'),
                        label: 'Skip',
                        onPressed: _continueToAuthentication,
                        variant: AppButtonVariant.ghost,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  key: const ValueKey('onboarding-page-view'),
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    const OnboardingWelcomePage(),
                    const OnboardingWhyKyvenPage(),
                    OnboardingGoalsPage(
                      selectedGoals: _selectedGoals,
                      onGoalToggled: _toggleGoal,
                    ),
                    OnboardingActivityLevelPage(
                      selectedLevel: _activityLevel,
                      onLevelSelected: (level) =>
                          setState(() => _activityLevel = level),
                    ),
                    const OnboardingPermissionsEducationPage(),
                    const OnboardingCompletionPage(),
                  ],
                ),
              ),
              AppResponsiveContent(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.page,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OnboardingStepProgress(
                      currentStep: _currentPage,
                      stepCount: _pageCount,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      key: ValueKey('onboarding-primary-$primaryLabel'),
                      label: primaryLabel,
                      onPressed: _advance,
                      icon: isLastPage
                          ? Icons.arrow_forward_rounded
                          : Icons.arrow_right_alt_rounded,
                    ),
                    if (isFirstPage) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        key: const ValueKey('onboarding-secondary-skip'),
                        label: 'Skip',
                        onPressed: _continueToAuthentication,
                        variant: AppButtonVariant.ghost,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
