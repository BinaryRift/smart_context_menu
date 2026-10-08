import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';

/// Builds [child] moved by [motion], animating each change, so the preview
/// and the slivers above it move together.
///
/// [builder] applies the offset: with [Transform.translate] for a box,
/// with [SliverPaintOffset] for a sliver.
final class SmartContextMenuMotion extends StatelessWidget {
  final ValueListenable<Offset> motion;
  final Widget Function(BuildContext context, Offset offset, Widget child)
  builder;
  final Widget child;

  const SmartContextMenuMotion({
    super.key,
    required this.motion,
    required this.builder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: motion,
      builder: (context, offset, child) {
        return TweenAnimationBuilder<Offset>(
          duration: MotionDurations.fast,
          curve: MotionCurves.entrance,
          tween: Tween<Offset>(begin: offset, end: offset),
          builder: (context, animatedOffset, child) {
            return builder(context, animatedOffset, child!);
          },
          child: child,
        );
      },
      child: child,
    );
  }
}
