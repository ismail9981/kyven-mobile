import 'package:flutter/animation.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_palette.dart';

class RunMapConfig {
  const RunMapConfig._();

  static const initialCenter = LatLng(25.2048, 55.2708);
  static const defaultZoom = 16.5;
  static const minimumZoom = 3.0;
  static const maximumZoom = 19.0;
  static const followAnimationDuration = Duration(milliseconds: 850);
  static const followAnimationCurve = Curves.easeOutCubic;
  static const maximumFollowFrequency = Duration(milliseconds: 900);
  static const userAgentPackageName = 'com.kyven.mobile';
  static const openStreetMapTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const minimumPolylinePoints = 2;
  static const routeLineWidth = 5.5;
  static const routeBorderWidth = 2.25;
  static const routeLineColor = AppPalette.lime;
  static const routeBorderColor = AppPalette.ink;
}
