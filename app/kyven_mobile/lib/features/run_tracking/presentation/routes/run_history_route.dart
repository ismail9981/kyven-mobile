import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route.dart';
import '../../../../core/theme/app_durations.dart';
import '../screens/run_detail_screen.dart';
import '../screens/run_history_screen.dart';

abstract final class RunHistoryRoute {
  static GoRoute get route => GoRoute(
    name: AppRoute.runHistory.name,
    path: AppRoute.runHistory.path,
    pageBuilder: (context, state) =>
        _page(state, child: const RunHistoryScreen()),
    routes: [
      GoRoute(
        name: AppRoute.runDetail.name,
        path: AppRoute.runDetail.path.replaceFirst(
          '${AppRoute.runHistory.path}/',
          '',
        ),
        pageBuilder: (context, state) => _page(
          state,
          child: RunDetailScreen(runId: state.pathParameters['runId'] ?? ''),
        ),
      ),
    ],
  );

  static CustomTransitionPage<void> _page(
    GoRouterState state, {
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppDurations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
