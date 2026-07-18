import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../screens/home_screen.dart';

abstract final class HomeRoute {
  static StatefulShellBranch get branch => StatefulShellBranch(
    routes: [
      GoRoute(
        name: AppRoute.home.name,
        path: AppRoute.home.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
    ],
  );
}
