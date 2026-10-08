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
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}
