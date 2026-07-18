import 'package:go_router/go_router.dart';

import '../../../../app/router/app_page_transitions.dart';
import '../../../../app/router/app_route.dart';
import '../screens/activities_screen.dart';

abstract final class ActivitiesRoute {
  static GoRoute get route => GoRoute(
    name: AppRoute.activities.name,
    path: AppRoute.activities.path,
    pageBuilder: (context, state) => AppPageTransitions.fadeSlide(
      state: state,
      child: const ActivitiesScreen(),
    ),
  );
}
