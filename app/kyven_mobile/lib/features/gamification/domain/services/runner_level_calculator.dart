class RunnerLevelSnapshot {
  const RunnerLevelSnapshot({
    required this.level,
    required this.levelStartXp,
    required this.nextLevelXp,
    required this.xpIntoCurrentLevel,
    required this.xpRequiredForNextLevel,
    required this.progressFraction,
  });

  final int level;
  final int levelStartXp;
  final int nextLevelXp;
  final double progressFraction;
  final int xpIntoCurrentLevel;
  final int xpRequiredForNextLevel;
}

class RunnerLevelCalculator {
  const RunnerLevelCalculator();

  static const _thresholds = [0, 250, 600, 1000, 1500];

  RunnerLevelSnapshot calculate(int totalXp) {
    final clampedXp = totalXp < 0 ? 0 : totalXp;
    final level = levelFromXp(clampedXp);
    final start = xpAtLevelStart(level);
    final next = xpAtLevelStart(level + 1);
    final required = (next - start).clamp(1, 1 << 31);
    final into = (clampedXp - start).clamp(0, required);
    return RunnerLevelSnapshot(
      level: level,
      levelStartXp: start,
      nextLevelXp: next,
      xpIntoCurrentLevel: into,
      xpRequiredForNextLevel: required,
      progressFraction: (into / required).clamp(0, 1),
    );
  }

  int levelFromXp(int totalXp) {
    final clampedXp = totalXp < 0 ? 0 : totalXp;
    var level = 1;
    while (xpAtLevelStart(level + 1) <= clampedXp) {
      level += 1;
    }
    return level;
  }

  int xpAtLevelStart(int level) {
    if (level <= 1) {
      return 0;
    }
    if (level <= _thresholds.length) {
      return _thresholds[level - 1];
    }
    final extraLevel = level - _thresholds.length;
    final previous = xpAtLevelStart(level - 1);
    return previous + 500 + (extraLevel * 150);
  }
}
