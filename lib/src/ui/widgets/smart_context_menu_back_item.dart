import 'dart:ui' show ImageFilter;
// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart'
    show CupertinoDynamicColor, CupertinoIcons;
import 'package:flutter/widgets.dart';

import '../../core/ui/styles/smart_context_menu_defaults.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../keys/service_item_key.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../view/item/smart_context_menu_item_view.dart';
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
  /// Has the menu background or
  /// [SmartContextMenuBackButtonStyle.decoration] and
  /// [SmartContextMenuBackButtonStyle.blur], and keeps drags on it from
  /// scrolling the items below.
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
    final backStyle = style.backButtonStyle;
    final item = SmartContextMenuItemView(
      key: _isPlaceholder
          ? ServiceItemKey.backPlaceholder
          : ServiceItemKey.back,
      onTap: (_) => onTap(),
      config: config,
      hoverController: hoverController,
      item: SmartContextMenuItem.simple(
        onTap: onTap,
        closeOnTap: false,
        title: config.labels.back,
        titleStyle: style.titleStyle
            .merge(backStyle.titleStyle)
            .copyWith(color: backStyle.foregroundColor),
        leading: Icon(
          backStyle.icon == SmartContextMenuDefaults.backIcon &&
                  Directionality.of(context) == TextDirection.rtl
              ? CupertinoIcons.chevron_forward
              : backStyle.icon,
          size: style.defaultIconSize,
          color: CupertinoDynamicColor.maybeResolve(
            backStyle.foregroundColor ?? style.defaultIconColor,
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

    final decoration = backStyle.decoration;
    final background = DecoratedBox(
      decoration:
          decoration ??
          BoxDecoration(
            color: CupertinoDynamicColor.resolve(style.menuColor, context),
            borderRadius: backStyle.borderRadius,
          ),
      child: itemWithDivider,
    );

    final Widget decoratedItem;
    if (decoration case final decoration?) {
      final blur = backStyle.blur;
      decoratedItem = ClipPath(
        clipper: _BackItemDecorationClipper(
          decoration: decoration,
          textDirection: Directionality.of(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: blur == null
            ? background
            : BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blur.sigmaX,
                  sigmaY: blur.sigmaY,
                ),
                child: background,
              ),
      );
    } else {
      decoratedItem = SmartContextMenuBlurBox(
        blur: backStyle.blur,
        borderRadius: backStyle.borderRadius,
        child: background,
      );
    }

    return GestureDetector(
      onPanStart: (_) {},
      behavior: HitTestBehavior.opaque,
      child: decoratedItem,
    );
  }
}

final class _BackItemDecorationClipper extends CustomClipper<Path> {
  final Decoration decoration;
  final TextDirection textDirection;

  const _BackItemDecorationClipper({
    required this.decoration,
    required this.textDirection,
  });

  @override
  Path getClip(Size size) =>
      decoration.getClipPath(Offset.zero & size, textDirection);

  @override
  bool shouldReclip(_BackItemDecorationClipper oldClipper) =>
      decoration != oldClipper.decoration ||
      textDirection != oldClipper.textDirection;
}
