import 'package:go_router/go_router.dart';

import '../../../../app/router/app_page_transitions.dart';
import '../../../../app/router/app_route.dart';
import '../screens/design_system_screen.dart';

abstract final class DesignSystemRoute {
  static GoRoute get route => GoRoute(
    name: AppRoute.designSystem.name,
    path: AppRoute.designSystem.path,
    pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
      state: state,
      child: const DesignSystemScreen(),
    ),
  );
}
