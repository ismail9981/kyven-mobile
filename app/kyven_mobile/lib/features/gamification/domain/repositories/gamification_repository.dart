import '../entities/gamification_profile.dart';

abstract interface class GamificationRepository {
  Future<GamificationProfile> loadState();

  Future<void> saveState(GamificationProfile state);

  Future<void> clearState();
}
