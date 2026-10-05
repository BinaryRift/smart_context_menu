import 'package:flutter/widgets.dart';

import '../../core/ui/styles/smart_context_menu_defaults.dart';

final class SmartContextMenuShadowBox extends StatelessWidget {
  final Widget child;
  const SmartContextMenuShadowBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: SmartContextMenuDefaults.borderRadius,
        boxShadow: SmartContextMenuDefaults.menuShadows,
      ),
      child: child,
    );
  }
}
