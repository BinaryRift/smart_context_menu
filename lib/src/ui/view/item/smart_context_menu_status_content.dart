// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/widgets.dart';

import '../../../domain/smart_context_menu_config.dart';
import '../../../domain/smart_context_menu_item.dart';
import '../../../domain/smart_context_menu_row_size.dart';
import 'smart_context_menu_item_cell.dart';
import 'smart_context_menu_item_row.dart';

/// The content of a loading, error or empty item.
///
/// Shows [SmartContextMenuStatusItem.child] in the item color, or a row
/// with the title and the sign of the state after it, unless the item has
/// its own. In a cell of a row, with [rowSize], it shows the sign of the
/// state, and in a medium cell the title below it, without the leading and
/// the trailing of the item.
final class SmartContextMenuStatusContent extends StatelessWidget {
  final SmartContextMenuStatusItem item;
  final SmartContextMenuConfig config;

  /// The color of the title and of icons without their own color.
  final Color foregroundColor;

  /// Whether the item stands for a failed load that the menu retries on
  /// tap: then it shows the retry title and icon.
  final bool retries;

  /// The size of the cell if the item is shown in a row.
  final SmartContextMenuRowSize? rowSize;

  const SmartContextMenuStatusContent({
    super.key,
    required this.item,
    required this.config,
    required this.foregroundColor,
    this.retries = false,
    this.rowSize,
  });

  @override
  Widget build(BuildContext context) {
    final style = config.style;

    if (item.child case final child?) {
      return DefaultTextStyle.merge(
        style: (item.titleStyle ?? style.titleStyle).copyWith(
          color: foregroundColor,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: foregroundColor),
          child: child,
        ),
      );
    }

    final labels = config.labels;
    final statusStyle = style.statusStyle;
    // The titles in a list and in a row, and the sign of the state.
    final (String title, String rowTitle, Widget sign) = switch (item) {
      _ when retries => (
        labels.retry,
        labels.rowRetry,
        Icon(statusStyle.retryIcon, size: style.defaultIconSize),
      ),
      SmartContextMenuLoadingItem() => (
        labels.loading,
        labels.rowLoading,
        // As large as the icons of other items.
        statusStyle.loadingIndicator ??
            CupertinoActivityIndicator(radius: style.defaultIconSize / 2),
      ),
      SmartContextMenuErrorItem() => (
        labels.error,
        labels.rowError,
        Icon(statusStyle.errorIcon, size: style.defaultIconSize),
      ),
      SmartContextMenuEmptyItem() => (
        labels.empty,
        labels.rowEmpty,
        Icon(statusStyle.emptyIcon, size: style.defaultIconSize),
      ),
    };
    if (rowSize case final size?) {
      return SmartContextMenuItemCell(
        title: item.title ?? rowTitle,
        titleStyle: item.titleStyle,
        leading: sign,
        childrenGap: item.childrenGap,
        size: size,
        style: style,
        foregroundColor: foregroundColor,
      );
    }
    return SmartContextMenuItemRow(
      title: item.title ?? title,
      titleStyle: item.titleStyle,
      leading: item.leading,
      trailing: item.trailing ?? sign,
      childrenGap: item.childrenGap,
      style: style,
      foregroundColor: foregroundColor,
      titleAlign: statusStyle.titleAlign,
    );
  }
}
