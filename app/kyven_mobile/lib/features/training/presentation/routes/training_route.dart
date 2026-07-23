import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../screens/training_plan_detail_screen.dart';
import '../screens/training_screen.dart';

abstract final class TrainingRoute {
  static StatefulShellBranch get branch => StatefulShellBranch(
    routes: [
      GoRoute(
        name: AppRoute.training.name,
        path: AppRoute.training.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const TrainingScreen(),
        ),
        routes: [
          GoRoute(
            name: AppRoute.trainingDetail.name,
            path: ':planId',
            builder: (context, state) {
              return TrainingPlanDetailScreen(
                planId: state.pathParameters['planId'] ?? '',
              );
            },
          ),
        ],
      ),
    ],
  );
}
