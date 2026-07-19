import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../screens/live_run_screen.dart';
import '../screens/run_summary_screen.dart';
import '../screens/start_run_screen.dart';

abstract final class StartRunRoute {
  static StatefulShellBranch get branch => StatefulShellBranch(
    routes: [
      GoRoute(
        name: AppRoute.run.name,
        path: AppRoute.run.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const StartRunScreen(),
        ),
        routes: [
          GoRoute(
            name: AppRoute.runLive.name,
            path: _childPath(AppRoute.runLive),
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const LiveRunScreen(),
            ),
          ),
          GoRoute(
            name: AppRoute.runSummary.name,
            path: _childPath(AppRoute.runSummary),
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const RunSummaryScreen(),
            ),
          ),
        ],
      ),
    ],
  );

  static String _childPath(AppRoute route) =>
      route.path.replaceFirst('${AppRoute.run.path}/', '');
}
