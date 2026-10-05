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
      child: SizeTransition(
        fixedCrossAxisSizeFactor: fixedCrossAxisSizeFactor,
        sizeFactor: animation,
        axis: axis,
        alignment: switch (axis) {
          Axis.horizontal => AlignmentDirectional(axisAlignment, -1),
          Axis.vertical => AlignmentDirectional(-1, axisAlignment),
        },
        child: child,
      ),
    );
  }
}
