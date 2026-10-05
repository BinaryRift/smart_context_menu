import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/material.dart' show Divider;
import 'package:flutter/widgets.dart';

/// The default divider of a menu item.
final class SmartContextMenuDivider extends StatelessWidget {
  /// The divider color, resolved for the current theme.
  final Color color;

  const SmartContextMenuDivider({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: CupertinoDynamicColor.resolve(color, context),
    );
  }
}
