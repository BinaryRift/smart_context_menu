import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/widgets.dart';

final class SmartContextMenuShadowBox extends StatelessWidget {
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow> shadows;
  final Widget child;

  const SmartContextMenuShadowBox({
    super.key,
    required this.borderRadius,
    required this.shadows,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
  }
}
