import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
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
      ),
    ],
  );
}
