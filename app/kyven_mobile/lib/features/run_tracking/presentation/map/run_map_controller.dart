import 'package:flutter/animation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'run_map_config.dart';

class RunMapController {
  RunMapController({
    required TickerProvider vsync,
    MapController? mapController,
  }) : mapController = mapController ?? MapController(),
       _animationController = AnimationController(
         vsync: vsync,
         duration: RunMapConfig.followAnimationDuration,
       );

  final MapController mapController;
  final AnimationController _animationController;

  var _isReady = false;

  void markReady() {
    _isReady = true;
  }

  void animateTo({
    required LatLng target,
    required double zoom,
    Curve curve = RunMapConfig.followAnimationCurve,
  }) {
    if (!_isReady) {
      return;
    }

    final camera = mapController.camera;
    final centerTween = _LatLngTween(begin: camera.center, end: target);
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom);
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: curve,
    );

    _animationController
      ..stop()
      ..reset();

    void listener() {
      mapController.move(
        centerTween.evaluate(animation),
        zoomTween.evaluate(animation),
      );
    }

    _animationController
      ..addListener(listener)
      ..forward().whenCompleteOrCancel(() {
        _animationController.removeListener(listener);
      });
  }

  void dispose() {
    _animationController.dispose();
  }
}

class _LatLngTween extends Tween<LatLng> {
  _LatLngTween({required super.begin, required super.end});

  @override
  LatLng lerp(double t) {
    final begin = this.begin ?? RunMapConfig.initialCenter;
    final end = this.end ?? RunMapConfig.initialCenter;
    return LatLng(
      begin.latitude + (end.latitude - begin.latitude) * t,
      begin.longitude + (end.longitude - begin.longitude) * t,
    );
  }
}
