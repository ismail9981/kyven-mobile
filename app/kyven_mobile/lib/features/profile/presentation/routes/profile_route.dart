import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../screens/profile_screen.dart';

abstract final class ProfileRoute {
  static StatefulShellBranch get branch => StatefulShellBranch(
    routes: [
      GoRoute(
        name: AppRoute.profile.name,
        path: AppRoute.profile.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
    ],
  );
}
