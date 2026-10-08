import 'package:flutter/widgets.dart';

/// Scrolls only while [isOverflowing] returns true.
///
/// [isOverflowing] is a callback rather than a value: [Scrollable] keeps
/// physics of the same type when it rebuilds, so a new value would be
/// ignored.
final class SmartMenuReactivePhysics extends BouncingScrollPhysics {
  final ValueGetter<bool> isOverflowing;

  const SmartMenuReactivePhysics({required this.isOverflowing, super.parent});

  @override
  SmartMenuReactivePhysics applyTo(ScrollPhysics? ancestor) {
    return SmartMenuReactivePhysics(
      isOverflowing: isOverflowing,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (!isOverflowing()) return 0.0;
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (!isOverflowing()) return null;
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SmartMenuReactivePhysics &&
          isOverflowing == other.isOverflowing;

  @override
  int get hashCode => Object.hash(super.hashCode, isOverflowing);
}
