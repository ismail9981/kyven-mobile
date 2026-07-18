import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

abstract final class AppKyvenSignature {
  static const Gradient velocityGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppPalette.electricCore,
      AppPalette.electric,
      AppPalette.violet,
      AppPalette.lime,
    ],
    stops: [0, 0.42, 0.72, 1],
  );
}

class AppKyvenVelocityField extends StatefulWidget {
  const AppKyvenVelocityField({this.intensity = 1, super.key});

  final double intensity;

  @override
  State<AppKyvenVelocityField> createState() => _AppKyvenVelocityFieldState();
}

class _AppKyvenVelocityFieldState extends State<AppKyvenVelocityField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _VelocityFieldPainter(
            progress: _controller.value,
            intensity: widget.intensity,
            isDark: isDark,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class AppKyvenCardMark extends StatelessWidget {
  const AppKyvenCardMark({this.color = AppPalette.electricBright, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _CardMarkPainter(color: color),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class AppKyvenMark extends StatelessWidget {
  const AppKyvenMark({this.size = 28, this.color = AppPalette.ink, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _KyvenMarkPainter(color: color),
      size: Size.square(size),
    );
  }
}

class _VelocityFieldPainter extends CustomPainter {
  const _VelocityFieldPainter({
    required this.progress,
    required this.intensity,
    required this.isDark,
  });

  final double intensity;
  final bool isDark;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [AppPalette.ink, AppPalette.inkRaised, AppPalette.charcoal]
            : const [
                AppPalette.frost,
                AppPalette.frostRaised,
                AppPalette.white,
              ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, base);

    final width = size.width;
    final height = size.height;
    final alpha = intensity * (isDark ? 0.13 : 0.08);
    final offset = (progress * width * 0.32) % (width * 0.32);

    final sheen = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppPalette.electric.withValues(alpha: alpha),
          AppPalette.violet.withValues(alpha: alpha * 0.62),
          AppPalette.transparent,
        ],
      ).createShader(Offset.zero & Size(width, height * 0.48));
    canvas.drawRect(Offset.zero & size, sheen);

    canvas
      ..save()
      ..translate(-width * 0.28 + offset, height * 0.2)
      ..rotate(-0.18);

    for (var i = 0; i < 5; i++) {
      final y = i * height * 0.09;
      final lane = Paint()
        ..shader = LinearGradient(
          colors: [
            AppPalette.transparent,
            (i.isEven ? AppPalette.lime : AppPalette.electricBright).withValues(
              alpha: alpha * (0.8 - i * 0.08),
            ),
            AppPalette.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, y, width * 1.42, 36));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, y, width * 1.42, 20),
          const Radius.circular(80),
        ),
        lane,
      );
    }
    canvas.restore();

    final grid = Paint()
      ..color = AppPalette.white.withValues(alpha: isDark ? 0.025 : 0.16)
      ..strokeWidth = 1;
    for (var x = -height; x < width + height; x += 42) {
      canvas.drawLine(
        Offset(x.toDouble(), height),
        Offset(x + height * 0.5, 0),
        grid,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VelocityFieldPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.intensity != intensity ||
      oldDelegate.isDark != isDark;
}

class _CardMarkPainter extends CustomPainter {
  const _CardMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final glow = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final start = Offset(size.width * 0.72, 0);
    for (var i = 0; i < 3; i++) {
      final inset = i * 14.0;
      final a = start.translate(inset, 0);
      final b = Offset(size.width + 12, size.height * 0.42 + inset);
      canvas
        ..drawLine(a, b, glow)
        ..drawLine(a, b, line);
    }
  }

  @override
  bool shouldRepaint(covariant _CardMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _KyvenMarkPainter extends CustomPainter {
  const _KyvenMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.15;
    final glow = Paint()
      ..color = color.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.22
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.16)
      ..lineTo(size.width * 0.22, size.height * 0.84)
      ..moveTo(size.width * 0.76, size.height * 0.18)
      ..lineTo(size.width * 0.34, size.height * 0.5)
      ..lineTo(size.width * 0.78, size.height * 0.82);
    final orbit = Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.5),
          radius: size.width * 0.42,
        ),
        -math.pi * 0.72,
        math.pi * 0.32,
      );
    canvas
      ..drawPath(path, glow)
      ..drawPath(path, stroke)
      ..drawPath(orbit, stroke..strokeWidth = size.width * 0.08);
  }

  @override
  bool shouldRepaint(covariant _KyvenMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
