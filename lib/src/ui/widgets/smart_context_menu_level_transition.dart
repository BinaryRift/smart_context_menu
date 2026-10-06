import 'package:flutter/widgets.dart';

import '../../core/ui/motion/tokens/motion_curves.dart';

/// Fades a menu level in and out with [animation] and slides it
/// by [position].
final class SmartContextMenuLevelTransition extends StatefulWidget {
  final Animation<double> animation;
  final Animation<Offset> position;
  final Widget child;

  const SmartContextMenuLevelTransition({
    super.key,
    required this.animation,
    required this.position,
    required this.child,
  });

  @override
  State<SmartContextMenuLevelTransition> createState() =>
      _SmartContextMenuLevelTransitionState();
}

final class _SmartContextMenuLevelTransitionState
    extends State<SmartContextMenuLevelTransition> {
  late CurvedAnimation _fade;

  @override
  void initState() {
    super.initState();
    _fade = _createFade();
  }

  @override
  void didUpdateWidget(SmartContextMenuLevelTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      _fade.dispose();
      _fade = _createFade();
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  CurvedAnimation _createFade() {
    return CurvedAnimation(
      parent: widget.animation,
      curve: MotionCurves.levelFadeIn,
      reverseCurve: MotionCurves.levelFadeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: widget.position, child: widget.child),
      ),
    );
  }
}
