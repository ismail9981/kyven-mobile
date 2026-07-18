import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../screens/challenges_screen.dart';

abstract final class ChallengesRoute {
  static StatefulShellBranch get branch => StatefulShellBranch(
    routes: [
      GoRoute(
        name: AppRoute.challenges.name,
        path: AppRoute.challenges.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ChallengesScreen(),
        ),
      ),
    ],
  );
}
