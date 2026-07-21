import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../application/run_location_state.dart';

class RunCurrentLocationMarker extends StatelessWidget {
  const RunCurrentLocationMarker({required this.signalStatus, super.key});

  final LocationSignalStatus signalStatus;

  @override
  Widget build(BuildContext context) {
    final color = switch (signalStatus) {
      LocationSignalStatus.ready => context.appColors.accent,
      LocationSignalStatus.weak => context.appColors.warning,
      LocationSignalStatus.searching => context.appColors.info,
      LocationSignalStatus.unavailable => context.appColors.error,
    };

    return Semantics(
      label: 'Current runner position',
      image: true,
      child: ExcludeSemantics(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          scale: signalStatus == LocationSignalStatus.ready ? 1 : 0.92,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppShadows.glow(color, opacity: 0.34),
            ),
            child: Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppPalette.ink.withValues(alpha: 0.86),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppPalette.white.withValues(alpha: 0.22),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  border: Border.all(
                    color: AppPalette.white.withValues(alpha: 0.82),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
