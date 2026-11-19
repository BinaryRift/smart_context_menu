// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_style.dart';

/// The divider of a menu item, drawn as set by [SmartContextMenuStyle].
final class SmartContextMenuDivider extends StatelessWidget {
  final SmartContextMenuStyle style;

  const SmartContextMenuDivider({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    final thickness = style.dividerThickness;
    return SizedBox(
      height: thickness,
      child: Center(
        child: Container(
          height: thickness,
          margin: EdgeInsetsDirectional.only(
            start: style.dividerIndent,
            end: style.dividerEndIndent,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: CupertinoDynamicColor.resolve(
                  style.dividerColor,
                  context,
                ),
                width: thickness,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
