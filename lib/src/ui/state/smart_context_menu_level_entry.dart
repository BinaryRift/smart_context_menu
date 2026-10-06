import 'package:flutter/widgets.dart';

import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_slides.dart';

/// A menu level on the screen with the animation of its appearance.
///
/// [controller] goes forward while the level comes in and in reverse
/// while it leaves.
final class SmartContextMenuLevelEntry {
  Widget child;
  final AnimationController controller;

  /// Where the level comes in from, as a fraction of its size.
  final Offset enterFrom;

  /// Where the level leaves to, or null while it has not started leaving.
  Offset? _exitTo;
  Offset _exitFrom = MotionSlide.none.offset;
  double _exitFromValue = 1;

  late final Animation<Offset> position = _LevelPosition(this);

  SmartContextMenuLevelEntry({
    required this.child,
    required this.controller,
    required this.enterFrom,
  });

  /// The current shift of the level, as a fraction of its size.
  Offset get offset {
    final exitTo = _exitTo;
    final value = controller.value;
    if (exitTo == null) {
      return Offset.lerp(enterFrom, MotionSlide.none.offset, _curve(value))!;
    }
    final progress = _exitFromValue == 0 ? 0.0 : value / _exitFromValue;
    return Offset.lerp(exitTo, _exitFrom, _curve(progress))!;
  }

  /// Leaves towards [to] from the current [offset], so a level
  /// interrupted halfway does not jump.
  TickerFuture leave(Offset to) {
    _exitFrom = offset;
    _exitFromValue = controller.value;
    _exitTo = to;
    return controller.reverse();
  }

  static double _curve(double value) =>
      MotionCurves.emphasized.transform(value.clamp(0.0, 1.0));
}

/// [SmartContextMenuLevelEntry.offset], updated with the level animation.
final class _LevelPosition extends Animation<Offset>
    with AnimationWithParentMixin<double> {
  final SmartContextMenuLevelEntry entry;

  _LevelPosition(this.entry);

  @override
  Animation<double> get parent => entry.controller;

  @override
  Offset get value => entry.offset;
}
