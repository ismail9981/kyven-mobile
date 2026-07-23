import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/features/gamification/application/gamification_providers.dart';
import 'package:kyven_mobile/features/run_tracking/application/run_history_providers.dart';

import '../../fakes/fake_gamification_repository.dart';
import '../../fakes/fake_run_history_repository.dart';
import '../../helpers/test_app.dart';

void main() {
  ProviderContainer container({
    required FakeRunHistoryRepository runs,
    required FakeGamificationRepository gamification,
  }) {
    final container = ProviderContainer(
      overrides: [
        runHistoryRepositoryProvider.overrideWithValue(runs),
        gamificationRepositoryProvider.overrideWithValue(gamification),
        gamificationNowProvider.overrideWithValue(DateTime(2026, 7, 20, 12)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('successfully saved completed run updates gamification', () async {
    final runs = FakeRunHistoryRepository();
    final gamification = FakeGamificationRepository();
    final ref = container(runs: runs, gamification: gamification);
    final run = savedRunFixture(
      id: 'run-1',
      distanceKm: 5,
      completedAt: DateTime(2026, 7, 20),
    );

    await runs.saveRun(run);
    final result = await ref
        .read(gamificationCoordinatorProvider)
        .processAfterRunSaved(run);

    expect(result.xpGranted, greaterThan(0));
    expect((await gamification.loadState()).processedRunIds, {'run-1'});
    expect(gamification.saveCount, 1);
  });

  test('failed run persistence does not grant rewards', () async {
    final gamification = FakeGamificationRepository();
    final state = await gamification.loadState();

    expect(state.totalXp, 0);
    expect(gamification.saveCount, 0);
  });

  test('training completion updates relevant progress', () async {
    final runs = FakeRunHistoryRepository();
    final gamification = FakeGamificationRepository();
    final ref = container(runs: runs, gamification: gamification);

    final result = await ref
        .read(gamificationCoordinatorProvider)
        .processTrainingSessionCompleted('plan:w1-d1');

    expect(result.xpGranted, 30);
    expect((await gamification.loadState()).processedTrainingSessionKeys, {
      'plan:w1-d1',
    });
  });

  test('same saved run processed twice clears old reward feedback', () async {
    final runs = FakeRunHistoryRepository();
    final gamification = FakeGamificationRepository();
    final ref = container(runs: runs, gamification: gamification);
    final run = savedRunFixture(
      id: 'run-1',
      completedAt: DateTime(2026, 7, 20),
    );
    await runs.saveRun(run);

    await ref.read(gamificationCoordinatorProvider).processAfterRunSaved(run);
    expect(ref.read(latestGamificationRewardProvider), isNotNull);

    final second = await ref
        .read(gamificationCoordinatorProvider)
        .processAfterRunSaved(run);
    expect(second.xpGranted, 0);
    expect(ref.read(latestGamificationRewardProvider), isNull);
  });
}
