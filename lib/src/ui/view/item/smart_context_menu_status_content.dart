import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/widgets.dart';

import '../../../domain/smart_context_menu_config.dart';
import '../../../domain/smart_context_menu_item.dart';
import 'smart_context_menu_item_row.dart';

/// The content of a loading, error or empty item.
///
/// Shows [SmartContextMenuStatusItem.child] in the item color, or a row
/// with the title and the sign of the state after it, unless the item has
/// its own.
final class SmartContextMenuStatusContent extends StatelessWidget {
  final SmartContextMenuStatusItem item;
  final SmartContextMenuConfig config;

  /// The color of the title and of icons without their own color.
  final Color foregroundColor;

  /// Whether the item stands for a failed load that the menu retries on
  /// tap: then it shows the retry title and icon.
  final bool retries;

  const SmartContextMenuStatusContent({
    super.key,
    required this.item,
    required this.config,
    required this.foregroundColor,
    this.retries = false,
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
    final (String title, Widget sign) = switch (item) {
      _ when retries => (
        labels.retry,
        Icon(style.retryIcon, size: style.defaultIconSize),
      ),
      SmartContextMenuLoadingItem() => (
        labels.loading,
        // As large as the icons of other items.
        style.loadingIndicator ??
            CupertinoActivityIndicator(radius: style.defaultIconSize / 2),
      ),
      SmartContextMenuErrorItem() => (
        labels.error,
        Icon(style.errorIcon, size: style.defaultIconSize),
      ),
      SmartContextMenuEmptyItem() => (
        labels.empty,
        Icon(style.emptyIcon, size: style.defaultIconSize),
      ),
    };
    return SmartContextMenuItemRow(
      title: item.title ?? title,
      titleStyle: item.titleStyle,
      leading: item.leading,
      trailing: item.trailing ?? sign,
      childrenGap: item.childrenGap,
      style: style,
      foregroundColor: foregroundColor,
      titleAlign: style.statusTitleAlign,
    );
  }
}
