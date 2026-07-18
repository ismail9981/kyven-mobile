import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/home_dashboard.dart';
import '../domain/repositories/home_dashboard_repository.dart';
import '../infrastructure/repositories/mock_home_dashboard_repository.dart';

final homeDashboardRepositoryProvider = Provider<HomeDashboardRepository>(
  (ref) => const MockHomeDashboardRepository(),
);

final homeDashboardProvider = Provider<HomeDashboard>(
  (ref) => ref.watch(homeDashboardRepositoryProvider).getDashboard(),
);
