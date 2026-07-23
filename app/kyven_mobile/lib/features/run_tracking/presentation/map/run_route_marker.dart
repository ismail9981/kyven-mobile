import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';

enum RunRouteMarkerType { start, finish }

class RunRouteMarker extends StatelessWidget {
  const RunRouteMarker.start({super.key}) : type = RunRouteMarkerType.start;

  const RunRouteMarker.finish({super.key}) : type = RunRouteMarkerType.finish;

  final RunRouteMarkerType type;

  @override
  Widget build(BuildContext context) {
    final isStart = type == RunRouteMarkerType.start;
    final color = isStart ? context.appColors.success : context.appColors.error;
    final icon = isStart ? Icons.play_arrow_rounded : Icons.flag_rounded;
    final label = isStart ? 'Route start marker' : 'Route finish marker';

    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppPalette.ink.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(AppRadii.full),
            border: Border.all(color: color.withValues(alpha: 0.84), width: 2),
            boxShadow: AppShadows.glow(color, opacity: 0.28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}
