import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/widgets.dart';

import '../../../domain/smart_context_menu_item.dart';
import '../../../domain/smart_context_menu_style.dart';

/// The default content of an item: [SmartContextMenuItem.leading], the
/// title, [SmartContextMenuItem.trailing] and the submenu chevron.
final class SmartContextMenuItemRow extends StatelessWidget {
  final SmartContextMenuItem item;
  final SmartContextMenuStyle style;

  /// The color of the title and of icons without their own color.
  final Color foregroundColor;
  final TextAlign titleAlign;

  const SmartContextMenuItemRow({
    super.key,
    required this.item,
    required this.style,
    required this.foregroundColor,
    this.titleAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(width: item.childrenGap ?? style.itemChildrenGap);
    return IconTheme.merge(
      data: IconThemeData(color: foregroundColor),
      child: Row(
        children: [
          if (item.leading case final leading?) ...[leading, gap],
          Expanded(
            child: Text(
              item.title ?? "",
              style: (item.titleStyle ?? style.titleStyle).copyWith(
                color: foregroundColor,
              ),
              textAlign: titleAlign,
              maxLines: style.titleMaxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.trailing case final trailing?) ...[gap, trailing],
          if (item.showTransitionIcon) ...[
            gap,
            Icon(
              style.submenuIcon,
              size: style.defaultIconSize,
              color: item.isDisabled
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
