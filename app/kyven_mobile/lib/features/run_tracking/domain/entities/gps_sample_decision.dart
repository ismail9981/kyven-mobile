enum GpsSampleDecision {
  accepted,
  rejectedAccuracy,
  rejectedTimestamp,
  rejectedDuplicate,
  rejectedStationaryNoise,
  rejectedImpossibleJump,
  rejectedInsufficientWarmup,
}

extension GpsSampleDecisionX on GpsSampleDecision {
  bool get isAccepted => this == GpsSampleDecision.accepted;
}
