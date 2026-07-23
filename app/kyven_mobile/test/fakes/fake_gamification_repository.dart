import 'package:kyven_mobile/features/gamification/domain/entities/gamification_profile.dart';
import 'package:kyven_mobile/features/gamification/domain/repositories/gamification_repository.dart';

class FakeGamificationRepository implements GamificationRepository {
  FakeGamificationRepository([GamificationProfile? state])
    : _state = state ?? GamificationProfile.empty();

  GamificationProfile _state;
  var saveCount = 0;

  @override
  Future<void> clearState() async {
    _state = GamificationProfile.empty();
  }

  @override
  Future<GamificationProfile> loadState() async => _state;

  @override
  Future<void> saveState(GamificationProfile state) async {
    saveCount += 1;
    _state = state;
  }
}
