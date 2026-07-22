import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/run_route.dart';
import 'run_map_config.dart';

class RunRoutePolylines extends StatelessWidget {
  const RunRoutePolylines({required this.route, super.key});

  final RunRoute route;

  static List<Polyline> polylinesFor(RunRoute route) {
    return route.segments
        .where(
          (segment) =>
              segment.points.length >= RunMapConfig.minimumPolylinePoints,
        )
        .map(
          (segment) => Polyline(
            points: segment.points
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList(growable: false),
            color: RunMapConfig.routeLineColor,
            strokeWidth: RunMapConfig.routeLineWidth,
            borderColor: RunMapConfig.routeBorderColor,
            borderStrokeWidth: RunMapConfig.routeBorderWidth,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final polylines = polylinesFor(route);
    if (polylines.isEmpty) {
      return const SizedBox.shrink();
    }
    return PolylineLayer(polylines: polylines);
  }
}
