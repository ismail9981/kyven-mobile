import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/run_location_state.dart';
import '../../domain/entities/run_route.dart';
import 'run_current_location_marker.dart';
import 'run_map_camera_controller.dart';
import 'run_map_config.dart';
import 'run_map_controller.dart';
import 'run_route_polylines.dart';

class RunMap extends ConsumerStatefulWidget {
  const RunMap({
    required this.locationState,
    required this.route,
    this.enableTiles = true,
    this.enableInteractiveMap = true,
    super.key,
  });

  final bool enableInteractiveMap;
  final bool enableTiles;
  final RunLocationState locationState;
  final RunRoute route;

  @override
  ConsumerState<RunMap> createState() => _RunMapState();
}

class _RunMapState extends ConsumerState<RunMap>
    with SingleTickerProviderStateMixin {
  late final RunMapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RunMapController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCameraForCurrentLocation();
    });
  }

  @override
  void didUpdateWidget(covariant RunMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final point = widget.locationState.currentLocation;
    if (point == null || point == oldWidget.locationState.currentLocation) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCameraForCurrentLocation();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(runMapCameraControllerProvider, (previous, next) {
      if (previous?.target == next.target && previous?.zoom == next.zoom) {
        return;
      }
      _controller.animateTo(target: next.target, zoom: next.zoom);
    });

    final cameraState = ref.watch(runMapCameraControllerProvider);
    final location = widget.locationState.currentLocation;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.ink,
          boxShadow: AppShadows.low(Theme.of(context).brightness),
        ),
        child: Stack(
          children: [
            Listener(
              onPointerMove: (_) => ref
                  .read(runMapCameraControllerProvider.notifier)
                  .disableFollowForUserGesture(),
              child: widget.enableInteractiveMap
                  ? FlutterMap(
                      key: const ValueKey('run-map'),
                      mapController: _controller.mapController,
                      options: MapOptions(
                        initialCenter: location == null
                            ? RunMapConfig.initialCenter
                            : LatLng(location.latitude, location.longitude),
                        initialZoom: RunMapConfig.defaultZoom,
                        minZoom: RunMapConfig.minimumZoom,
                        maxZoom: RunMapConfig.maximumZoom,
                        onMapReady: _controller.markReady,
                      ),
                      children: [
                        if (widget.enableTiles)
                          TileLayer(
                            urlTemplate: RunMapConfig.openStreetMapTileUrl,
                            userAgentPackageName:
                                RunMapConfig.userAgentPackageName,
                          )
                        else
                          const _RunMapTestSurface(),
                        RunRoutePolylines(route: widget.route),
                        MarkerLayer(
                          markers: [
                            if (location != null)
                              Marker(
                                point: LatLng(
                                  location.latitude,
                                  location.longitude,
                                ),
                                width: 54,
                                height: 54,
                                child: RunCurrentLocationMarker(
                                  signalStatus:
                                      widget.locationState.signalStatus,
                                ),
                              ),
                          ],
                        ),
                      ],
                    )
                  : _RunMapStaticSurface(locationState: widget.locationState),
            ),
            const _RunMapScrim(),
            if (location == null)
              _WaitingForGpsOverlay(state: widget.locationState),
            if (!cameraState.isFollowing && location != null)
              _RestoreFollowButton(
                onPressed: () => ref
                    .read(runMapCameraControllerProvider.notifier)
                    .restoreFollow(location),
              ),
          ],
        ),
      ),
    );
  }

  void _updateCameraForCurrentLocation() {
    if (!mounted) return;
    final point = widget.locationState.currentLocation;
    if (point == null) {
      return;
    }
    ref
        .read(runMapCameraControllerProvider.notifier)
        .updateLocation(point, now: point.recordedAt);
  }
}

class _RunMapScrim extends StatelessWidget {
  const _RunMapScrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppPalette.black.withValues(alpha: 0.18),
              AppPalette.black.withValues(alpha: 0),
              AppPalette.black.withValues(alpha: 0.34),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RunMapStaticSurface extends StatelessWidget {
  const _RunMapStaticSurface({required this.locationState});

  final RunLocationState locationState;

  @override
  Widget build(BuildContext context) {
    final location = locationState.currentLocation;
    return Stack(
      key: const ValueKey('run-map'),
      children: [
        const _RunMapTestSurface(),
        if (location != null)
          Center(
            child: RunCurrentLocationMarker(
              signalStatus: locationState.signalStatus,
            ),
          ),
      ],
    );
  }
}

class _WaitingForGpsOverlay extends StatelessWidget {
  const _WaitingForGpsOverlay({required this.state});

  final RunLocationState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = state.userMessage ?? 'Waiting for a clean GPS signal.';
    return ColoredBox(
      color: AppPalette.black.withValues(alpha: 0.42),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.gps_not_fixed_rounded,
                  color: context.appColors.info,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  state.gpsLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.appColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RestoreFollowButton extends StatelessWidget {
  const _RestoreFollowButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: AppSpacing.md,
      bottom: AppSpacing.md,
      child: Semantics(
        button: true,
        label: 'Re-center map on current location',
        child: AppPressedScale(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.full),
          child: Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppPalette.ink.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(AppRadii.full),
              border: Border.all(
                color: AppPalette.white.withValues(alpha: 0.16),
              ),
              boxShadow: AppShadows.low(Theme.of(context).brightness),
            ),
            child: Icon(
              Icons.my_location_rounded,
              color: context.appColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _RunMapTestSurface extends StatelessWidget {
  const _RunMapTestSurface();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppPalette.graphite,
      child: CustomPaint(
        painter: _RunMapGridPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RunMapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppPalette.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const step = 36.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
