import 'package:flutter/widgets.dart';

/// Fades [child] with [opacity] and slides it by [position].
final class FadeSlideTransition extends StatelessWidget {
  final Animation<double> opacity;
  final Animation<Offset> position;
  final Widget child;

  const FadeSlideTransition({
    super.key,
    required this.opacity,
    required this.position,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: opacity,
        child: SlideTransition(position: position, child: child),
      ),
    );
  }
}
