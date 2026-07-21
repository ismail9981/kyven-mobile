enum LocationPermissionStatus {
  unknown,
  denied,
  deniedForever,
  whileInUse,
  always,
}

extension LocationPermissionStatusX on LocationPermissionStatus {
  bool get isGranted =>
      this == LocationPermissionStatus.whileInUse ||
      this == LocationPermissionStatus.always;
}
