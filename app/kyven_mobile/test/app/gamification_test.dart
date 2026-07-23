import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kyven_mobile/core/theme/app_durations.dart';
import 'package:kyven_mobile/core/theme/app_theme.dart';
import 'package:kyven_mobile/features/challenges/presentation/screens/challenges_screen.dart';
import 'package:kyven_mobile/features/gamification/domain/entities/gamification_profile.dart';
import 'package:kyven_mobile/features/gamification/domain/entities/gamification_update_result.dart';
import 'package:kyven_mobile/features/gamification/domain/entities/unlocked_achievement.dart';
import 'package:kyven_mobile/features/gamification/domain/services/built_in_achievement_catalog.dart';
import 'package:kyven_mobile/features/gamification/domain/services/built_in_challenge_catalog.dart';
import 'package:kyven_mobile/features/gamification/presentation/widgets/gamification_reward_card.dart';

import '../fakes/fake_gamification_repository.dart';
import '../helpers/test_app.dart';

void main() {
  Future<void> openChallenges(
    WidgetTester tester, {
    FakeGamificationRepository? gamification,
  }) async {
    await tester.pumpWidget(testApp(gamificationRepository: gamification));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    await tester.tap(find.byKey(const ValueKey('navigation-Challenges')));
    await tester.pump();
    await tester.pump(AppDurations.slow);
  }

  testWidgets(
    'empty Challenges screen renders XP, challenges, achievements, and streak',
    (tester) async {
      await openChallenges(tester);

      expect(find.byType(ChallengesScreen), findsOneWidget);
      expect(
        find.byKey(const ValueKey('gamification-level-header')),
        findsOneWidget,
      );
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Weekly Challenges'), findsOneWidget);
      expect(find.byKey(const ValueKey('challenge-weekly_5k')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('achievement-first_run')),
        findsOneWidget,
      );
      expect(find.text('Locked · +100 XP'), findsOneWidget);
      expect(find.text('Current Streak'), findsOneWidget);
    },
  );

  testWidgets('unlocked achievement state renders unlock date', (tester) async {
    final profile = GamificationProfile.empty().copyWith(
      unlockedAchievements: [
        UnlockedAchievement(
          achievementId: 'first_run',
          unlockedAt: DateTime(2026, 7, 20),
          xpGranted: 100,
        ),
      ],
    );
    await openChallenges(
      tester,
      gamification: FakeGamificationRepository(profile),
    );

    expect(find.text('Unlocked 7/20/2026'), findsOneWidget);
  });

  testWidgets('reward summary card renders XP and level up feedback', (
    tester,
  ) async {
    final result = GamificationUpdateResult(
      updatedProfile: GamificationProfile.empty().copyWith(totalXp: 300),
      updatedChallengeProgress: const [],
      newlyCompletedChallenges: [BuiltInChallengeCatalog.all.first],
      newlyUnlockedAchievements: [BuiltInAchievementCatalog.all.first],
      xpGranted: 300,
      levelBefore: 1,
      levelAfter: 2,
      didLevelUp: true,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: GamificationRewardCard(result: result)),
      ),
    );

    expect(
      find.byKey(const ValueKey('gamification-reward-card')),
      findsOneWidget,
    );
    expect(find.text('+300 XP'), findsOneWidget);
    expect(find.text('Level 2 reached'), findsOneWidget);
  });
}
