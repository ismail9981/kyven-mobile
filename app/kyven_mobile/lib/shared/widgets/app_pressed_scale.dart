import 'package:flutter/material.dart';

import '../../core/theme/app_durations.dart';

class AppPressedScale extends StatefulWidget {
  const AppPressedScale({
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.borderRadius,
    super.key,
  });

  final BorderRadius? borderRadius;
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<AppPressedScale> createState() => _AppPressedScaleState();
}

class _AppPressedScaleState extends State<AppPressedScale> {
  var _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    Widget result = AnimatedScale(
      scale: _pressed && !reduceMotion ? widget.scale : 1,
      duration: reduceMotion ? AppDurations.instant : AppDurations.fast,
      curve: AppCurves.standard,
      child: widget.child,
    );
    if (widget.borderRadius case final radius?) {
      result = ClipRRect(borderRadius: radius, child: result);
    }

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
        onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
        onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
        child: result,
      ),
    );
  }
}
