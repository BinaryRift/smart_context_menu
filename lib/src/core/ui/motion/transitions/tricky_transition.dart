import 'dart:math' as math;

import 'package:flutter/material.dart';

final class TrickyTransition extends StatelessWidget {
  final Animation<double> animation;
  final double axisAlignment;
  final Axis axis;
  final double? fixedCrossAxisSizeFactor;
  final Widget child;

  const TrickyTransition({
    super.key,
    required this.animation,
    required this.child,
    this.axisAlignment = 0.0,
    this.axis = Axis.vertical,
    this.fixedCrossAxisSizeFactor,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final sizeFactor = math.max(animation.value, 0.0);
          return ClipRect(
            // Clips only while the size animates, so a child that paints a
            // little outside its box, such as the stroke of a
            // CircularProgressIndicator, is not cut once it is shown.
            clipBehavior: sizeFactor < 1 ? Clip.hardEdge : Clip.none,
            child: Align(
              alignment: switch (axis) {
                Axis.horizontal => AlignmentDirectional(axisAlignment, -1),
                Axis.vertical => AlignmentDirectional(-1, axisAlignment),
              },
              heightFactor: axis == Axis.vertical
                  ? sizeFactor
                  : fixedCrossAxisSizeFactor,
              widthFactor: axis == Axis.horizontal
                  ? sizeFactor
                  : fixedCrossAxisSizeFactor,
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }
}
