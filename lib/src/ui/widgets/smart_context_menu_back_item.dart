import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../keys/service_item_key.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../view/smart_context_menu_item_view.dart';
import 'smart_context_menu_blur_box.dart';
import 'smart_context_menu_divider.dart';

/// The item that returns to the parent menu level.
final class SmartContextMenuBackItem extends StatelessWidget {
  final SmartContextMenuConfig config;
  final SmartContextMenuHoverController hoverController;
  final VoidCallback onTap;
  final bool _isPlaceholder;

  /// The back item pinned to the top of a submenu.
  ///
  /// Has the menu background and [SmartContextMenuStyle.backButtonBlur],
  /// and keeps drags on it from scrolling the items below.
  const SmartContextMenuBackItem({
    super.key,
    required this.config,
    required this.hoverController,
    required this.onTap,
  }) : _isPlaceholder = false;

  /// The invisible copy that reserves the space of the pinned back item
  /// at the top of the submenu list.
  const SmartContextMenuBackItem.placeholder({
    super.key,
    required this.config,
    required this.hoverController,
    required this.onTap,
  }) : _isPlaceholder = true;

  @override
  Widget build(BuildContext context) {
    final style = config.style;
    final item = SmartContextMenuItemView(
      key: _isPlaceholder
          ? ServiceItemKey.backPlaceholder
          : ServiceItemKey.back,
      onTap: (_) => onTap(),
      config: config,
      hoverController: hoverController,
      item: SmartContextMenuItem.simple(
        closeOnTap: false,
        title: config.labels.back,
        titleStyle: style.titleStyle
            .merge(style.backButtonTitleStyle)
            .copyWith(color: style.backButtonColor),
        leading: Icon(
          style.backIcon,
          size: style.defaultIconSize,
          color: CupertinoDynamicColor.maybeResolve(
            style.backButtonColor ?? style.defaultIconColor,
            context,
          ),
        ),
      ),
    );
    final itemWithDivider = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        item,
        SmartContextMenuDivider(style: style),
      ],
    );

    if (_isPlaceholder) {
      return Visibility.maintain(
        visible: false,
        child: IgnorePointer(child: itemWithDivider),
      );
    }

    return GestureDetector(
      onPanStart: (_) {},
      behavior: HitTestBehavior.opaque,
      child: SmartContextMenuBlurBox(
        blur: style.backButtonBlur,
        borderRadius: style.backButtonBorderRadius,
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(style.menuColor, context),
            borderRadius: style.backButtonBorderRadius,
          ),
          child: itemWithDivider,
        ),
      ),
    );
  }
}
