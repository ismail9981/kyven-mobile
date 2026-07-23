import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:kyven_mobile/features/gamification/domain/entities/gamification_profile.dart';
import 'package:kyven_mobile/features/gamification/domain/entities/unlocked_achievement.dart';
import 'package:kyven_mobile/features/gamification/infrastructure/repositories/gamification_schema.dart';
import 'package:kyven_mobile/features/gamification/infrastructure/repositories/hive_gamification_repository.dart';

void main() {
  late Directory directory;
  late String boxName;
  late HiveGamificationRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('kyven-gamification-');
    boxName = 'gamification_${DateTime.now().microsecondsSinceEpoch}';
    repository = HiveGamificationRepository(
      storageDirectory: directory.path,
      boxName: boxName,
    );
  });

  tearDown(() async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).close();
    }
    await Hive.deleteBoxFromDisk(boxName, path: directory.path);
    await directory.delete(recursive: true);
  });

  test('empty state load is safe', () async {
    expect(await repository.loadState(), GamificationProfile.empty());
  });

  test('save and restore gamification state', () async {
    final profile = GamificationProfile.empty().copyWith(
      totalXp: 250,
      processedRunIds: {'run-1'},
      claimedChallengeRewardKeys: {'weekly_5k:2026-07-20'},
      unlockedAchievements: [
        UnlockedAchievement(
          achievementId: 'first_run',
          unlockedAt: DateTime(2026, 7, 20),
          xpGranted: 100,
        ),
      ],
    );

    await repository.saveState(profile);
    final restored = await repository.loadState();

    expect(restored.totalXp, 250);
    expect(restored.processedRunIds, {'run-1'});
    expect(restored.claimedChallengeRewardKeys, {'weekly_5k:2026-07-20'});
    expect(restored.unlockedAchievementIds, {'first_run'});
  });

  test(
    'legacy missing fields and malformed optional data load safely',
    () async {
      final box = await Hive.openBox<dynamic>(boxName, path: directory.path);
      await box.put(GamificationSchema.versionKey, GamificationSchema.version);
      await box.put(GamificationSchema.profileKey, {
        'totalXp': 10,
        'unlockedAchievements': ['bad-record'],
      });

      final profile = await repository.loadState();
      expect(profile.totalXp, 10);
      expect(profile.processedRunIds, isEmpty);
      expect(profile.unlockedAchievements, isEmpty);
    },
  );
}
