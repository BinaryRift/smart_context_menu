import 'dart:ui' show ImageFilter;
// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart'
    show CupertinoDynamicColor, CupertinoIcons;
import 'package:flutter/widgets.dart';

import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/styles/smart_context_menu_defaults.dart';
import '../../domain/smart_context_menu_blur.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../keys/service_item_key.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../view/item/smart_context_menu_item_view.dart';
import 'smart_context_menu_blur_box.dart';
import 'smart_context_menu_divider.dart';

/// The item that returns to the parent menu level.
final class SmartContextMenuBackItem extends StatelessWidget {
  static const _glassDividerColor = CupertinoDynamicColor.withBrightness(
    color: Color(0x2E000000),
    darkColor: Color(0x38FFFFFF),
  );

  final SmartContextMenuConfig config;
  final SmartContextMenuHoverController hoverController;
  final VoidCallback onTap;
  final Color? glassTint;
  final bool hasItemsUnderBack;
  final bool _isPlaceholder;

  /// The back item pinned to the top of a submenu.
  ///
  /// Draws the back item background and keeps drags on it from scrolling
  /// the items below.
  const SmartContextMenuBackItem({
    super.key,
    required this.config,
    required this.hoverController,
    required this.onTap,
    this.glassTint,
    this.hasItemsUnderBack = false,
  }) : _isPlaceholder = false;

  /// The invisible copy that reserves the space of the pinned back item
  /// at the top of the submenu list.
  const SmartContextMenuBackItem.placeholder({
    super.key,
    required this.config,
    required this.hoverController,
    required this.onTap,
  }) : glassTint = null,
       hasItemsUnderBack = false,
       _isPlaceholder = true;

  @override
  Widget build(BuildContext context) {
    final style = config.style;
    final backStyle = style.backButtonStyle;
    final decoration = backStyle.decoration;
    final glassTint = decoration == null ? this.glassTint : null;
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
        SmartContextMenuDivider(
          style: style,
          color:
              glassTint != null &&
                  style.dividerColor == SmartContextMenuDefaults.dividerColor
              ? _glassDividerColor
              : null,
        ),
      ],
    );

    if (_isPlaceholder) {
      return Visibility.maintain(
        visible: false,
        child: IgnorePointer(child: itemWithDivider),
      );
    }

    // The glass surface already clips the top corners of the default row.
    final borderRadius =
        glassTint != null &&
            backStyle.borderRadius ==
                SmartContextMenuDefaults.backButtonBorderRadius
        ? BorderRadius.zero
        : backStyle.borderRadius;
    final background = DecoratedBox(
      decoration:
          decoration ??
          BoxDecoration(
            color:
                glassTint?.withValues(alpha: 0.14) ??
                CupertinoDynamicColor.resolve(style.menuColor, context),
            borderRadius: borderRadius,
          ),
      child: itemWithDivider,
    );

    final blur = backStyle.blur;
    final Widget decoratedItem;
    if (decoration case final decoration?) {
      decoratedItem = _buildCustomBackground(
        context,
        decoration: decoration,
        blur: blur,
        child: background,
      );
    } else if (glassTint != null && blur == SmartContextMenuBlur.strong) {
      decoratedItem = _buildAnimatedGlassBackground(
        context,
        blur: blur,
        borderRadius: borderRadius,
        child: background,
      );
    } else {
      decoratedItem = _buildDefaultBackground(
        blur: blur,
        borderRadius: borderRadius,
        child: background,
      );
    }

    return GestureDetector(
      onPanStart: (_) {},
      behavior: HitTestBehavior.opaque,
      child: decoratedItem,
    );
  }

  Widget _buildCustomBackground(
    BuildContext context, {
    required Decoration decoration,
    required SmartContextMenuBlur? blur,
    required Widget child,
  }) {
    return ClipPath(
      clipper: _BackItemDecorationClipper(
        decoration: decoration,
        textDirection: Directionality.of(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: blur == null
          ? child
          : BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blur.sigmaX,
                sigmaY: blur.sigmaY,
              ),
              child: child,
            ),
    );
  }

  Widget _buildAnimatedGlassBackground(
    BuildContext context, {
    required SmartContextMenuBlur? blur,
    required BorderRadiusGeometry borderRadius,
    required Widget child,
  }) {
    final targetStrength = hasItemsUnderBack ? 1.0 : 0.0;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: targetStrength, end: targetStrength),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : MotionDurations.fast,
      curve: MotionCurves.standard,
      builder: (context, strength, child) => SmartContextMenuBlurBox(
        blur: blur,
        borderRadius: borderRadius,
        strength: strength,
        child: child!,
      ),
      child: child,
    );
  }

  Widget _buildDefaultBackground({
    required SmartContextMenuBlur? blur,
    required BorderRadiusGeometry borderRadius,
    required Widget child,
  }) {
    return SmartContextMenuBlurBox(
      blur: blur,
      borderRadius: borderRadius,
      child: child,
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
