import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/location_point.dart';
import 'run_map_config.dart';

final runMapCameraControllerProvider =
    NotifierProvider<RunMapCameraController, RunMapCameraState>(
      RunMapCameraController.new,
    );

class RunMapCameraState extends Equatable {
  const RunMapCameraState({
    this.target = RunMapConfig.initialCenter,
    this.zoom = RunMapConfig.defaultZoom,
    this.isFollowing = true,
    this.lastFollowedAt,
  });

  final bool isFollowing;
  final DateTime? lastFollowedAt;
  final LatLng target;
  final double zoom;

  RunMapCameraState copyWith({
    LatLng? target,
    double? zoom,
    bool? isFollowing,
    DateTime? lastFollowedAt,
    bool clearLastFollowedAt = false,
  }) {
    return RunMapCameraState(
      target: target ?? this.target,
      zoom: zoom ?? this.zoom,
      isFollowing: isFollowing ?? this.isFollowing,
      lastFollowedAt: clearLastFollowedAt
          ? null
          : lastFollowedAt ?? this.lastFollowedAt,
    );
  }

  @override
  List<Object?> get props => [target, zoom, isFollowing, lastFollowedAt];
}

class RunMapCameraController extends Notifier<RunMapCameraState> {
  @override
  RunMapCameraState build() => const RunMapCameraState();

  void updateLocation(LocationPoint point, {DateTime? now}) {
    if (!state.isFollowing) {
      return;
    }

    final timestamp = now ?? DateTime.now();
    final lastFollowedAt = state.lastFollowedAt;
    if (lastFollowedAt != null &&
        timestamp.difference(lastFollowedAt) <
            RunMapConfig.maximumFollowFrequency) {
      return;
    }

    state = state.copyWith(
      target: LatLng(point.latitude, point.longitude),
      lastFollowedAt: timestamp,
    );
  }

  void disableFollowForUserGesture() {
    if (!state.isFollowing) {
      return;
    }
    state = state.copyWith(isFollowing: false);
  }

  void restoreFollow(LocationPoint? point, {DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    state = state.copyWith(
      isFollowing: true,
      target: point == null
          ? state.target
          : LatLng(point.latitude, point.longitude),
      lastFollowedAt: timestamp,
    );
  }
}
