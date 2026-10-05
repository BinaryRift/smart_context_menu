import 'package:flutter/widgets.dart';

final class SmartMenuReactivePhysics extends BouncingScrollPhysics {
  final ValueNotifier<double> heightNotifier;
  final double heightThreshold;

  bool get _isOverflowing => heightNotifier.value > heightThreshold;

  const SmartMenuReactivePhysics({
    required this.heightNotifier,
    required this.heightThreshold,
    super.parent,
  });

  @override
  SmartMenuReactivePhysics applyTo(ScrollPhysics? ancestor) {
    return SmartMenuReactivePhysics(
      heightNotifier: heightNotifier,
      heightThreshold: heightThreshold,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (!_isOverflowing) return 0.0;
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (!_isOverflowing) return null;
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SmartMenuReactivePhysics &&
          heightNotifier == other.heightNotifier &&
          heightThreshold == other.heightThreshold;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        heightNotifier,
        heightThreshold,
      );
}
