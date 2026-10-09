import 'dart:ui' as ui show ImageFilter;

import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/widgets.dart';

import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_opacity.dart';
import '../../domain/smart_context_menu_blur.dart';

/// The dimmed and blurred screen behind the open menu.
///
/// Fades in and blurs with [animation]. The blur grows by its strength and
/// stays out of the fade: on the web, a backdrop filter under an opacity
/// layer is not drawn until the layer is gone, so the blur would appear
/// at once at the end.
final class SmartContextMenuBackground extends StatefulWidget {
  final Animation<double> animation;
  final Color color;
  final SmartContextMenuBlur? blur;

  const SmartContextMenuBackground({
    super.key,
    required this.animation,
    required this.color,
    this.blur,
  });

  @override
  State<SmartContextMenuBackground> createState() =>
      _SmartContextMenuBackgroundState();
}

final class _SmartContextMenuBackgroundState
    extends State<SmartContextMenuBackground> {
  late final CurvedAnimation _curve;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _curve = CurvedAnimation(
      parent: widget.animation,
      curve: MotionCurves.quartOut,
      reverseCurve: MotionCurves.quartIn,
    );
    _opacity = Tween<double>(
      begin: MotionOpacity.hidden.value,
      end: MotionOpacity.visible.value,
    ).animate(_curve);
  }

  @override
  void dispose() {
    _curve.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blur = widget.blur;
    final background = ColoredBox(
      color: CupertinoDynamicColor.resolve(widget.color, context),
    );

    final dimming = FadeTransition(opacity: _opacity, child: background);
    if (blur == null) return dimming;

    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: blur.sigmaX * _curve.value,
            sigmaY: blur.sigmaY * _curve.value,
          ),
          child: child,
        );
      },
      child: dimming,
    );
  }
}
