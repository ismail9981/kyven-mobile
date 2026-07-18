import 'package:go_router/go_router.dart';

import '../../../../app/router/app_page_transitions.dart';
import '../../../../app/router/app_route.dart';
import '../screens/notifications_screen.dart';

abstract final class NotificationsRoute {
  static GoRoute get route => GoRoute(
    name: AppRoute.notifications.name,
    path: AppRoute.notifications.path,
    pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
      state: state,
      child: const NotificationsScreen(),
    ),
  );
}
