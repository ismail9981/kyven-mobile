import 'package:go_router/go_router.dart';

import '../../../../app/router/app_page_transitions.dart';
import '../../../../app/router/app_route.dart';
import '../screens/goal_detail_screen.dart';
import '../screens/goal_form_screen.dart';
import '../screens/goals_screen.dart';

abstract final class GoalsRoute {
  static List<GoRoute> get routes => [
    GoRoute(
      name: AppRoute.goals.name,
      path: AppRoute.goals.path,
      pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
        state: state,
        child: const GoalsScreen(),
      ),
    ),
    GoRoute(
      name: AppRoute.goalCreate.name,
      path: AppRoute.goalCreate.path,
      pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
        state: state,
        child: const GoalFormScreen(),
      ),
    ),
    GoRoute(
      name: AppRoute.goalDetail.name,
      path: AppRoute.goalDetail.path,
      pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
        state: state,
        child: GoalDetailScreen(goalId: state.pathParameters['goalId'] ?? ''),
      ),
    ),
    GoRoute(
      name: AppRoute.goalEdit.name,
      path: AppRoute.goalEdit.path,
      pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
        state: state,
        child: GoalFormScreen(goalId: state.pathParameters['goalId'] ?? ''),
      ),
    ),
  ];
}
