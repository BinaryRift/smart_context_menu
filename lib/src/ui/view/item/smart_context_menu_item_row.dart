import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/widgets.dart';

import '../../../domain/smart_context_menu_item.dart';
import '../../../domain/smart_context_menu_style.dart';

/// The default content of an item: [leading], [title], [trailing] and
/// the submenu chevron.
final class SmartContextMenuItemRow extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final Widget? leading;
  final Widget? trailing;
  final double? childrenGap;

  /// Whether the row ends with the submenu chevron.
  final bool hasSubmenu;

  /// Whether the item is disabled: the chevron is dimmed then.
  final bool isDisabled;
  final SmartContextMenuStyle style;

  /// The color of the title and of icons without their own color.
  final Color foregroundColor;
  final TextAlign titleAlign;

  const SmartContextMenuItemRow({
    super.key,
    required this.title,
    this.titleStyle,
    this.leading,
    this.trailing,
    this.childrenGap,
    this.hasSubmenu = false,
    this.isDisabled = false,
    required this.style,
    required this.foregroundColor,
    this.titleAlign = TextAlign.start,
  });

  /// The row of [item]: its fields and the chevron if it opens a submenu.
  SmartContextMenuItemRow.content({
    super.key,
    required SmartContextMenuContentItem item,
    required this.style,
    required this.foregroundColor,
  }) : title = item.title ?? "",
       titleStyle = item.titleStyle,
       leading = item.leading,
       trailing = item.trailing,
       childrenGap = item.childrenGap,
       hasSubmenu = item is! SmartContextMenuSimpleItem,
       isDisabled = item.isDisabled,
       titleAlign = TextAlign.start;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(width: childrenGap ?? style.itemChildrenGap);
    return IconTheme.merge(
      data: IconThemeData(color: foregroundColor),
      child: Row(
        children: [
          if (leading case final leading?) ...[leading, gap],
          Expanded(
            child: Text(
              title,
              style: (titleStyle ?? style.titleStyle).copyWith(
                color: foregroundColor,
              ),
              textAlign: titleAlign,
              maxLines: style.titleMaxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing case final trailing?) ...[gap, trailing],
          if (hasSubmenu) ...[
            gap,
            Icon(
              style.submenuIcon,
              size: style.defaultIconSize,
              color: isDisabled
                  ? CupertinoDynamicColor.resolve(
                      style.disabledForegroundColor,
                      context,
                    )
                  : CupertinoDynamicColor.maybeResolve(
                      style.defaultIconColor,
                      context,
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
