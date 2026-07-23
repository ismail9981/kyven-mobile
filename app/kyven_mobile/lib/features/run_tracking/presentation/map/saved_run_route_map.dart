import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../domain/entities/run_route.dart';
import '../../domain/entities/run_route_point.dart';
import 'run_map_config.dart';
import 'run_route_marker.dart';
import 'run_route_polylines.dart';

class SavedRunRouteMap extends StatelessWidget {
  const SavedRunRouteMap({required this.route, super.key});

  final RunRoute route;

  @override
  Widget build(BuildContext context) {
    final coordinates = _coordinates(route);
    if (coordinates.length < RunMapConfig.minimumPolylinePoints) {
      return const SizedBox.shrink();
    }

    final start = _firstPoint(route);
    final finish = _lastPoint(route);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.ink,
          boxShadow: AppShadows.low(Theme.of(context).brightness),
        ),
        child: FlutterMap(
          key: const ValueKey('saved-run-route-map'),
          options: MapOptions(
            initialCameraFit: CameraFit.coordinates(
              coordinates: coordinates,
              padding: RunMapConfig.historyRoutePadding,
              maxZoom: RunMapConfig.historyRouteMaxZoom,
            ),
            minZoom: RunMapConfig.minimumZoom,
            maxZoom: RunMapConfig.maximumZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: RunMapConfig.openStreetMapTileUrl,
              userAgentPackageName: RunMapConfig.userAgentPackageName,
            ),
            RunRoutePolylines(route: route),
            MarkerLayer(
              markers: [
                if (start != null)
                  Marker(
                    point: LatLng(start.latitude, start.longitude),
                    width: 44,
                    height: 44,
                    child: const RunRouteMarker.start(),
                  ),
                if (finish != null)
                  Marker(
                    point: LatLng(finish.latitude, finish.longitude),
                    width: 44,
                    height: 44,
                    child: const RunRouteMarker.finish(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static List<LatLng> _coordinates(RunRoute route) {
    return route.segments
        .expand((segment) => segment.points)
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
  }

  static RunRoutePoint? _firstPoint(RunRoute route) {
    for (final segment in route.segments) {
      if (segment.points.isNotEmpty) {
        return segment.points.first;
      }
    }
    return null;
  }

  static RunRoutePoint? _lastPoint(RunRoute route) {
    for (final segment in route.segments.reversed) {
      if (segment.points.isNotEmpty) {
        return segment.points.last;
      }
    }
    return null;
  }
}
