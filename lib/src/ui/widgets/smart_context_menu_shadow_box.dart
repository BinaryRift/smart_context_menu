import 'package:flutter/widgets.dart';

import '../../core/ui/styles/smart_context_menu_defaults.dart';

final class SmartContextMenuShadowBox extends StatelessWidget {
  final BorderRadiusGeometry borderRadius;
  final Widget child;

  const SmartContextMenuShadowBox({
    super.key,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: SmartContextMenuDefaults.menuShadows,
      ),
      child: child,
    );
  }
}
