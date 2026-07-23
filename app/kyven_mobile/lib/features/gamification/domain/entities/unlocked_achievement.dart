import 'package:equatable/equatable.dart';

class UnlockedAchievement extends Equatable {
  const UnlockedAchievement({
    required this.achievementId,
    required this.unlockedAt,
    required this.xpGranted,
  });

  final String achievementId;
  final DateTime unlockedAt;
  final int xpGranted;

  @override
  List<Object> get props => [achievementId, unlockedAt, xpGranted];
}
