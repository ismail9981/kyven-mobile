import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_durations.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';

class AppProgressRing extends StatelessWidget {
  const AppProgressRing({
    required this.progress,
    required this.size,
    required this.child,
    this.strokeWidth = AppSpacing.sm,
    this.trackColor,
    super.key,
  });

  final Widget child;
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: AppDurations.slow,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => CustomPaint(
        painter: _RingPainter(
          progress: value,
          trackColor: trackColor ?? scheme.outlineVariant,
          strokeWidth: strokeWidth,
          brightness: Theme.of(context).brightness,
        ),
        child: SizedBox.square(
          dimension: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.strokeWidth,
    required this.brightness,
  });

  final Brightness brightness;
  final double progress;
  final double strokeWidth;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final value = progress.clamp(0, 1).toDouble();
    final track = Paint()
      ..color = trackColor.withValues(
        alpha: brightness == Brightness.dark ? 0.54 : 0.72,
      )
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final vector = Paint()
      ..color = AppPalette.lime.withValues(
        alpha: brightness == Brightness.dark ? 0.68 : 0.78,
      )
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.5, strokeWidth * 0.18);
    final trackInset = Paint()
      ..color = AppPalette.white.withValues(
        alpha: brightness == Brightness.dark ? 0.07 : 0.38,
      )
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth * 0.42;
    final glow = Paint()
      ..shader = const SweepGradient(
        colors: [
          AppPalette.electric,
          AppPalette.violet,
          AppPalette.lime,
          AppPalette.electric,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth * 1.7
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    final active = Paint()
      ..shader = const SweepGradient(
        colors: [
          AppPalette.electric,
          AppPalette.violet,
          AppPalette.lime,
          AppPalette.electric,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final cap = Paint()
      ..color = AppPalette.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    final capAngle = -math.pi / 2 + (math.pi * 2 * value);
    final capOffset = Offset(
      center.dx + math.cos(capAngle) * radius,
      center.dy + math.sin(capAngle) * radius,
    );
    canvas
      ..drawCircle(center, radius, track)
      ..drawCircle(center, radius - strokeWidth * 0.36, trackInset)
      ..drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, glow)
      ..drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, active)
      ..drawCircle(capOffset, strokeWidth * 0.28, cap);

    for (final turn in const [0.12, 0.38, 0.64, 0.9]) {
      final angle = -math.pi / 2 + math.pi * 2 * turn;
      final inner = Offset(
        center.dx + math.cos(angle) * (radius - strokeWidth * 1.2),
        center.dy + math.sin(angle) * (radius - strokeWidth * 1.2),
      );
      final outer = Offset(
        center.dx + math.cos(angle + 0.08) * (radius + strokeWidth * 0.28),
        center.dy + math.sin(angle + 0.08) * (radius + strokeWidth * 0.28),
      );
      canvas.drawLine(inner, outer, vector);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.brightness != brightness;
}
