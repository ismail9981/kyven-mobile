extension RunDurationFormatting on Duration {
  String get timeLabel {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    if (inHours > 0) {
      return '$inHours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  String get paceLabel {
    if (this <= Duration.zero) return '--:--';
    final minutes = inMinutes.toString();
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

extension RunDistanceFormatting on double {
  String get distanceLabel => toStringAsFixed(2);
}

extension RunSpeedFormatting on double? {
  String get speedLabel {
    final speed = this;
    if (speed == null || !speed.isFinite || speed <= 0) return '--';
    return (speed * 3.6).toStringAsFixed(1);
  }
}
