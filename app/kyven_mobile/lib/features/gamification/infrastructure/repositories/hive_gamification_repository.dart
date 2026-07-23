import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../domain/entities/gamification_profile.dart';
import '../../domain/entities/unlocked_achievement.dart';
import '../../domain/repositories/gamification_repository.dart';
import 'gamification_failure.dart';
import 'gamification_schema.dart';

class HiveGamificationRepository implements GamificationRepository {
  HiveGamificationRepository({
    this.storageDirectory,
    this.boxName = GamificationSchema.boxName,
  });

  static bool _initialized = false;

  final String boxName;
  final String? storageDirectory;

  @override
  Future<void> clearState() async {
    final box = await _box();
    await box.delete(GamificationSchema.profileKey);
  }

  @override
  Future<GamificationProfile> loadState() async {
    final box = await _box();
    try {
      return _GamificationMapper.fromRecord(
            box.get(GamificationSchema.profileKey),
          ) ??
          GamificationProfile.empty();
    } catch (_) {
      return GamificationProfile.empty();
    }
  }

  @override
  Future<void> saveState(GamificationProfile state) async {
    final box = await _box();
    try {
      await box.put(
        GamificationSchema.profileKey,
        _GamificationMapper.toMap(state),
      );
    } catch (_) {
      throw const GamificationFailure('Gamification state could not be saved.');
    }
  }

  Future<Box<dynamic>> _box() async {
    await _ensureInitialized();
    try {
      final box = Hive.isBoxOpen(boxName)
          ? Hive.box<dynamic>(boxName)
          : await Hive.openBox<dynamic>(boxName, path: storageDirectory);
      final version = box.get(GamificationSchema.versionKey);
      if (version == null) {
        await box.put(
          GamificationSchema.versionKey,
          GamificationSchema.version,
        );
      } else if (version != GamificationSchema.version) {
        throw const GamificationFailure(
          'Gamification storage needs a migration.',
        );
      }
      return box;
    } on GamificationFailure {
      rethrow;
    } catch (_) {
      throw const GamificationFailure('Gamification storage is unavailable.');
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    try {
      if (storageDirectory == null) {
        await Hive.initFlutter('kyven');
      } else {
        Hive.init(storageDirectory);
      }
      _initialized = true;
    } catch (_) {
      throw const GamificationFailure('Gamification storage is unavailable.');
    }
  }
}

abstract final class _GamificationMapper {
  static Map<String, Object?> toMap(GamificationProfile state) {
    return {
      'totalXp': state.totalXp,
      'unlockedAchievements': state.unlockedAchievements
          .map(
            (achievement) => {
              'achievementId': achievement.achievementId,
              'unlockedAt': achievement.unlockedAt.toIso8601String(),
              'xpGranted': achievement.xpGranted,
            },
          )
          .toList(growable: false),
      'completedChallengeIds': state.completedChallengeIds.toList(
        growable: false,
      ),
      'claimedChallengeRewardKeys': state.claimedChallengeRewardKeys.toList(
        growable: false,
      ),
      'processedRunIds': state.processedRunIds.toList(growable: false),
      'processedTrainingSessionKeys': state.processedTrainingSessionKeys.toList(
        growable: false,
      ),
    };
  }

  static GamificationProfile? fromRecord(Object? record) {
    if (record is! Map) {
      return null;
    }
    return GamificationProfile.empty().copyWith(
      totalXp: _intValue(record['totalXp']) ?? 0,
      unlockedAchievements: _unlockedAchievements(
        record['unlockedAchievements'],
      ),
      completedChallengeIds: _stringSet(record['completedChallengeIds']),
      claimedChallengeRewardKeys: _stringSet(
        record['claimedChallengeRewardKeys'],
      ),
      processedRunIds: _stringSet(record['processedRunIds']),
      processedTrainingSessionKeys: _stringSet(
        record['processedTrainingSessionKeys'],
      ),
    );
  }

  static List<UnlockedAchievement> _unlockedAchievements(Object? record) {
    if (record is! Iterable) {
      return const [];
    }
    final achievements = <UnlockedAchievement>[];
    for (final item in record) {
      if (item is! Map) {
        continue;
      }
      final id = item['achievementId'];
      final unlockedAt = DateTime.tryParse('${item['unlockedAt']}');
      final xp = _intValue(item['xpGranted']);
      if (id is String && unlockedAt != null && xp != null) {
        achievements.add(
          UnlockedAchievement(
            achievementId: id,
            unlockedAt: unlockedAt,
            xpGranted: xp,
          ),
        );
      }
    }
    return achievements;
  }

  static Set<String> _stringSet(Object? record) {
    if (record is! Iterable) {
      return const {};
    }
    return record
        .map((value) => '$value')
        .where((value) => value.trim().isNotEmpty)
        .toSet();
  }

  static int? _intValue(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }
}
