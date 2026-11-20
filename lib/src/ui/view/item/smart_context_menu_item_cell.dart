import 'package:flutter/widgets.dart';

import '../../../domain/smart_context_menu_item.dart';
import '../../../domain/smart_context_menu_row_size.dart';
import '../../../domain/smart_context_menu_style.dart';
import 'smart_context_menu_item_row.dart';

/// The default content of an item in a cell of a [SmartContextMenuItem.row].
///
/// A medium cell shows [leading] above [title]. A small cell shows only
/// [leading], labeled with [title] for screen readers, or [title] without
/// [leading]. The content is centered and kept at the top of the cell.
///
/// A cell that opens a submenu shows a small submenu icon in its top corner
/// at the end of the line. The icon is placed from the edges of the cell, so
/// it takes [padding], the padding of the cell around this content, into
/// account.
///
/// Text in [leading] takes the style and the color of the title unless it
/// has its own; icons take the title color.
final class SmartContextMenuItemCell extends StatelessWidget {
  /// The distance of the submenu icon from the top and the end of the cell.
  static const double _submenuIconInset = 6;

  final String title;
  final TextStyle? titleStyle;
  final Widget? leading;
  final double? childrenGap;
  final SmartContextMenuRowSize size;
  final bool hasSubmenu;

  /// Whether the item is disabled: the submenu icon is dimmed then.
  final bool isDisabled;
  final EdgeInsets padding;
  final SmartContextMenuStyle style;

  /// The color of the title and of text and icons without their own color.
  final Color foregroundColor;

  const SmartContextMenuItemCell({
    super.key,
    required this.title,
    this.titleStyle,
    this.leading,
    this.childrenGap,
    required this.size,
    this.hasSubmenu = false,
    this.isDisabled = false,
    this.padding = EdgeInsets.zero,
    required this.style,
    required this.foregroundColor,
  });

  /// The cell of [item]: its title and leading, and the submenu icon if it
  /// opens a submenu.
  SmartContextMenuItemCell.content({
    super.key,
    required SmartContextMenuContentItem item,
    required this.size,
    required this.padding,
    required this.style,
    required this.foregroundColor,
  }) : title = item.title ?? "",
       titleStyle = item.titleStyle,
       leading = item.leading,
       childrenGap = item.childrenGap,
       hasSubmenu = item is! SmartContextMenuSimpleItem,
       isDisabled = item.isDisabled;

  @override
  Widget build(BuildContext context) {
    final textStyle = (titleStyle ?? style.titleStyle)
        .merge(style.rowStyle.titleStyle)
        .copyWith(color: foregroundColor);
    final titleText = Text(
      title,
      style: textStyle,
      textAlign: TextAlign.center,
      maxLines: style.titleMaxLines,
      overflow: TextOverflow.ellipsis,
    );
    final leading = this.leading;

    final List<Widget> children = switch (size) {
      SmartContextMenuRowSize.small when leading != null => [
        title.isEmpty ? leading : Semantics(label: title, child: leading),
      ],
      SmartContextMenuRowSize.small => [titleText],
      SmartContextMenuRowSize.medium => [
        ?leading,
        if (leading != null && title.isNotEmpty)
          SizedBox(height: childrenGap ?? style.rowStyle.itemChildrenGap),
        if (title.isNotEmpty || leading == null) titleText,
      ],
    };

    // As wide as the cell, so the content is centered in it and the submenu
    // icon is placed from its edge.
    Widget content = SizedBox(
      width: double.infinity,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
    if (hasSubmenu) {
      final isLtr = Directionality.of(context) == TextDirection.ltr;
      content = Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          content,
          PositionedDirectional(
            top: _submenuIconInset - padding.top,
            end: _submenuIconInset - (isLtr ? padding.right : padding.left),
            child: SmartContextMenuSubmenuIcon(
              style: style,
              size: style.defaultIconSize / 2,
              isDisabled: isDisabled,
            ),
          ),
        ],
      );
    }

    return DefaultTextStyle.merge(
      style: textStyle,
      child: IconTheme.merge(
        data: IconThemeData(color: foregroundColor),
        child: content,
      ),
    );
  }
}
