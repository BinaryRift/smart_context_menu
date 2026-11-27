// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/widgets.dart';

final class SmartContextMenuShadowBox extends StatelessWidget {
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow> shadows;
  final Animation<double>? opacity;
  final Widget child;

  const SmartContextMenuShadowBox({
    super.key,
    required this.borderRadius,
    required this.shadows,
    this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final shadowBox = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          for (final shadow in shadows)
            BoxShadow(
              color: CupertinoDynamicColor.resolve(shadow.color, context),
              offset: shadow.offset,
              blurRadius: shadow.blurRadius,
              spreadRadius: shadow.spreadRadius,
              blurStyle: shadow.blurStyle,
            ),
        ],
      ),
      child: child,
    );
    final opacity = this.opacity;
    if (opacity == null) return shadowBox;
    return AnimatedBuilder(
      animation: opacity,
      child: shadowBox,
      builder: (context, child) {
        final alpha = opacity.value.clamp(0.0, 1.0);
        if (alpha == 0) return const SizedBox.expand();
        if (alpha == 1) return child!;

        // Impeller's blurred rrect cannot accept inherited opacity.
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            const Color(0xFFFFFFFF).withValues(alpha: alpha),
            BlendMode.dstIn,
          ),
          child: child,
        );
      },
    );
  }
}
