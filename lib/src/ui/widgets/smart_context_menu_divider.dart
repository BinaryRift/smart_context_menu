import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/material.dart' show Divider;
import 'package:flutter/widgets.dart';

import '../../core/ui/styles/smart_context_menu_defaults.dart';

/// The default divider of a menu item.
final class SmartContextMenuDivider extends StatelessWidget {
  const SmartContextMenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: CupertinoDynamicColor.resolve(
        SmartContextMenuDefaults.dividerColor,
        context,
      ),
    );
  }
}
