import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/run_tracking/application/location_tracking_providers.dart';
import 'router/app_router.dart';

class KyvenApp extends ConsumerWidget {
  const KyvenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(runLocationLifecycleProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Kyven',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
