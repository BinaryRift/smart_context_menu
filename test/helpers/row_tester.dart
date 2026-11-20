// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_divider.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_row_layout.dart';

const transparent = Color(0x00000000);
const defaultStyle = SmartContextMenuStyle();

/// The rows drawn in the menu.
final rowLayouts = find.byType(SmartContextMenuRowLayout);

/// The vertical dividers between the cells of rows.
final rowDividers = find.byType(SmartContextMenuRowDivider);

/// A cell with an icon and [title] that adds its title to [taps] on tap and
/// keeps the menu open unless [closeOnTap] is true.
SmartContextMenuSimpleItem rowCell(
  String title, {
  List<String>? taps,
  bool closeOnTap = false,
  bool isDisabled = false,
  bool isDestructive = false,
}) {
  return SmartContextMenuItem.simple(
    title: title,
    leading: const Icon(CupertinoIcons.circle),
    closeOnTap: closeOnTap,
    isDisabled: isDisabled,
    isDestructive: isDestructive,
    onTap: () => taps?.add(title),
  );
}

/// Whether [color] is the default color of separators.
bool isSeparatorColor(Color? color) =>
    color?.toARGB32() ==
    SmartContextMenuDefaults.separatorColor.color.toARGB32();

extension RowTester on WidgetTester {
  /// The frame of the cell that shows [title]: its pressed area.
  Rect cellRectOf(String title) => getRect(
    find
        .ancestor(
          of: find.text(title),
          matching: find.byType(AnimatedContainer),
        )
        .first,
  );
}
