import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../run_tracking/application/run_history_providers.dart';
import '../../run_tracking/domain/entities/saved_run.dart';
import '../domain/entities/gamification_dashboard.dart';
import '../domain/entities/gamification_update_result.dart';
import '../domain/repositories/gamification_repository.dart';
import '../domain/services/built_in_achievement_catalog.dart';
import '../domain/services/built_in_challenge_catalog.dart';
import '../domain/services/gamification_engine.dart';
import '../infrastructure/repositories/hive_gamification_repository.dart';

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return HiveGamificationRepository();
});

final gamificationEngineProvider = Provider<GamificationEngine>(
  (ref) => const GamificationEngine(),
);

final gamificationNowProvider = Provider<DateTime>((ref) => DateTime.now());

final latestGamificationRewardProvider =
    NotifierProvider<
      LatestGamificationRewardNotifier,
      GamificationUpdateResult?
    >(LatestGamificationRewardNotifier.new);

class LatestGamificationRewardNotifier
    extends Notifier<GamificationUpdateResult?> {
  @override
  GamificationUpdateResult? build() => null;

  void show(GamificationUpdateResult result) {
    state = result.hasRewards ? result : null;
  }

  void clear() {
    state = null;
  }
}

final gamificationDashboardProvider = FutureProvider<GamificationDashboard>((
  ref,
) async {
  final runs = await ref.watch(runHistoryProvider.future);
  final repository = ref.watch(gamificationRepositoryProvider);
  final engine = ref.watch(gamificationEngineProvider);
  final now = ref.watch(gamificationNowProvider);
  final storedProfile = await repository.loadState();
  final profile = engine.refreshDerivedProfile(
    profile: storedProfile,
    runs: runs,
    now: now,
  );
  return GamificationDashboard(
    profile: profile,
    challenges: BuiltInChallengeCatalog.all,
    challengeProgress: engine.calculateChallengeProgress(
      runs: runs,
      profile: profile,
      now: now,
    ),
    achievements: BuiltInAchievementCatalog.all,
  );
});

final gamificationCoordinatorProvider = Provider<GamificationCoordinator>((
  ref,
) {
  return GamificationCoordinator(ref);
});

class GamificationCoordinator {
  GamificationCoordinator(this._ref);

  final Ref _ref;

  Future<GamificationUpdateResult> processAfterRunSaved(SavedRun run) async {
    final runRepository = _ref.read(runHistoryRepositoryProvider);
    final gamificationRepository = _ref.read(gamificationRepositoryProvider);
    final engine = _ref.read(gamificationEngineProvider);
    final now = _ref.read(gamificationNowProvider);
    final state = await gamificationRepository.loadState();
    final runs = await runRepository.getAllRuns();
    final result = engine.evaluate(runs: runs, currentProfile: state, now: now);
    if (result.updatedProfile != state) {
      await gamificationRepository.saveState(result.updatedProfile);
    }
    _ref.invalidate(gamificationDashboardProvider);
    _ref.read(latestGamificationRewardProvider.notifier).show(result);
    return result;
  }

  Future<GamificationUpdateResult> processTrainingSessionCompleted(
    String sessionKey,
  ) async {
    final runRepository = _ref.read(runHistoryRepositoryProvider);
    final gamificationRepository = _ref.read(gamificationRepositoryProvider);
    final engine = _ref.read(gamificationEngineProvider);
    final now = _ref.read(gamificationNowProvider);
    final state = await gamificationRepository.loadState();
    final runs = await runRepository.getAllRuns();
    final result = engine.evaluate(
      runs: runs,
      currentProfile: state,
      now: now,
      newlyCompletedTrainingSessionKeys: {sessionKey},
    );
    if (result.updatedProfile != state) {
      await gamificationRepository.saveState(result.updatedProfile);
    }
    _ref.invalidate(gamificationDashboardProvider);
    _ref.read(latestGamificationRewardProvider.notifier).show(result);
    return result;
  }
}
