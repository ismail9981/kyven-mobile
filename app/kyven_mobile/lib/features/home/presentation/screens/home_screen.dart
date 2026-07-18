import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/home_dashboard_providers.dart';
import '../widgets/home_hero.dart';
import '../widgets/home_sections.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SingleChildScrollView(
        key: const PageStorageKey('home-scroll'),
        child: AppResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppEntrance(child: GreetingHero(dashboard: dashboard)),
              const SizedBox(height: AppSpacing.xl),
              AppEntrance(
                child: StartRunHeroCard(
                  dashboard: dashboard,
                  onStartRun: () => context.goNamed(AppRoute.run.name),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppEntrance(
                child: TodayActivitySection(metrics: dashboard.todayMetrics),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppEntrance(
                child: WeeklyProgressSection(days: dashboard.weeklyProgress),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppEntrance(
                child: TrainingPlanPreviewSection(plan: dashboard.trainingPlan),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppEntrance(
                child: ChallengesPreviewSection(
                  challenges: dashboard.challenges,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppEntrance(
                child: RecentActivitySection(
                  activities: dashboard.recentActivities,
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
