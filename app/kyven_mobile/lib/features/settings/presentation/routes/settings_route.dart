import 'package:go_router/go_router.dart';

import '../../../../app/router/app_page_transitions.dart';
import '../../../../app/router/app_route.dart';
import '../screens/settings_screen.dart';

abstract final class SettingsRoute {
  static GoRoute get route => GoRoute(
    name: AppRoute.settings.name,
    path: AppRoute.settings.path,
    pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
      state: state,
      child: const SettingsScreen(),
    ),
  );
}
