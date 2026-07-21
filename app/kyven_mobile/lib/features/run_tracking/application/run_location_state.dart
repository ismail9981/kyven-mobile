import 'package:equatable/equatable.dart';

import '../domain/entities/location_permission_status.dart';
import '../domain/entities/location_point.dart';
import '../domain/failures/location_failure.dart';

enum LocationSignalStatus { searching, ready, weak, unavailable }

class RunLocationState extends Equatable {
  const RunLocationState({
    this.serviceEnabled = true,
    this.permissionStatus = LocationPermissionStatus.unknown,
    this.currentLocation,
    this.signalStatus = LocationSignalStatus.unavailable,
    this.failure,
    this.isChecking = false,
    this.isTracking = false,
  });

  final LocationPoint? currentLocation;
  final LocationFailure? failure;
  final bool isChecking;
  final bool isTracking;
  final LocationPermissionStatus permissionStatus;
  final bool serviceEnabled;
  final LocationSignalStatus signalStatus;

  bool get isReady => serviceEnabled && permissionStatus.isGranted;

  bool get canOpenAppSettings =>
      failure?.type == LocationFailureType.permissionDeniedForever;

  bool get canOpenLocationSettings =>
      failure?.type == LocationFailureType.serviceDisabled;

  String get gpsLabel {
    return switch (signalStatus) {
      LocationSignalStatus.searching => 'GPS Searching',
      LocationSignalStatus.ready => 'GPS Ready',
      LocationSignalStatus.weak => 'Weak Signal',
      LocationSignalStatus.unavailable => 'Location Unavailable',
    };
  }

  String get preparationLabel {
    if (isChecking) return 'GPS Checking';
    if (isReady) return 'GPS Ready';
    if (failure != null) return 'GPS Needs Attention';
    return 'GPS Preview';
  }

  String? get userMessage {
    final failure = this.failure;
    if (failure == null) return null;
    return switch (failure.type) {
      LocationFailureType.serviceDisabled =>
        'Turn on Location Services to start a GPS run.',
      LocationFailureType.permissionDenied =>
        'KYVEN needs location while you run. You can try again when you are ready.',
      LocationFailureType.permissionDeniedForever =>
        'Location access is off. Enable it in Settings to start a GPS run.',
      LocationFailureType.timeout =>
        'GPS is taking longer than expected. Step outside and try again.',
      LocationFailureType.unavailable =>
        'Location is unavailable right now. Try again in a moment.',
    };
  }

  RunLocationState copyWith({
    bool? serviceEnabled,
    LocationPermissionStatus? permissionStatus,
    LocationPoint? currentLocation,
    LocationSignalStatus? signalStatus,
    LocationFailure? failure,
    bool? isChecking,
    bool? isTracking,
    bool clearLocation = false,
    bool clearFailure = false,
  }) {
    return RunLocationState(
      serviceEnabled: serviceEnabled ?? this.serviceEnabled,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      currentLocation: clearLocation
          ? null
          : currentLocation ?? this.currentLocation,
      signalStatus: signalStatus ?? this.signalStatus,
      failure: clearFailure ? null : failure ?? this.failure,
      isChecking: isChecking ?? this.isChecking,
      isTracking: isTracking ?? this.isTracking,
    );
  }

  @override
  List<Object?> get props => [
    serviceEnabled,
    permissionStatus,
    currentLocation,
    signalStatus,
    failure,
    isChecking,
    isTracking,
  ];
}
