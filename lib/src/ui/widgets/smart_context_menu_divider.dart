import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/material.dart' show Divider;
import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_style.dart';

/// The divider of a menu item, drawn as set by [SmartContextMenuStyle].
final class SmartContextMenuDivider extends StatelessWidget {
  final SmartContextMenuStyle style;

  const SmartContextMenuDivider({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: style.dividerThickness,
      thickness: style.dividerThickness,
      indent: style.dividerIndent,
      endIndent: style.dividerEndIndent,
      color: CupertinoDynamicColor.resolve(style.dividerColor, context),
    );
  }
}
