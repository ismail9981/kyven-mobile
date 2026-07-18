import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/home_hero.dart';
import '../widgets/home_sections.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        key: const PageStorageKey('home-scroll'),
        child: AppResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppEntrance(child: HomeHeader()),
              const SizedBox(height: AppSpacing.xl),
              AppEntrance(
                child: WeeklyHero(
                  onStart: () => context.goNamed(AppRoute.run.name),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const AnimatedStats(),
              const SizedBox(height: AppSpacing.xl),
              const DailyChallenge(),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(
                title: 'Today’s signal',
                subtitle: 'Built around your current rhythm',
              ),
              const SizedBox(height: AppSpacing.md),
              const TrainingSignal(),
              const SizedBox(height: AppSpacing.xl),
              const AchievementStrip(),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(title: 'Last movement'),
              const SizedBox(height: AppSpacing.md),
              const RecentRun(),
            ],
          ),
        ),
      ),
    );
  }
}
