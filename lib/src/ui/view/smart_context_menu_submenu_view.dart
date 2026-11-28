import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_blur.dart';
import '../../domain/smart_context_menu_config.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../widgets/smart_context_menu_back_item.dart';
import '../widgets/widget_size_listener.dart';

/// Pins the back item above a submenu list and clips the list at the glass rim.
final class SmartContextMenuSubmenuView extends StatefulWidget {
  final Widget list;
  final SmartContextMenuConfig config;
  final SmartContextMenuHoverController hoverController;
  final VoidCallback onBack;
  final Color? glassTint;

  const SmartContextMenuSubmenuView({
    super.key,
    required this.list,
    required this.config,
    required this.hoverController,
    required this.onBack,
    this.glassTint,
  });

  @override
  State<SmartContextMenuSubmenuView> createState() =>
      _SmartContextMenuSubmenuViewState();
}

final class _SmartContextMenuSubmenuViewState
    extends State<SmartContextMenuSubmenuView> {
  // Covers the gap that can show above the back item during scrolling.
  static const double _backItemOverlap = 0.5;

  bool _hasItemsUnderBack = false;
  double _backItemHeight = 0;

  @override
  Widget build(BuildContext context) {
    final clipper = _glassBlurClipper(context);
    final stack = Stack(
      children: [
        _buildList(clipper),
        Positioned(
          top: -_backItemOverlap,
          left: 0,
          right: 0,
          child: _buildBackItem(clipper),
        ),
      ],
    );
    if (clipper == null) return stack;
    return NotificationListener<Notification>(
      onNotification: _updateBackItem,
      child: stack,
    );
  }

  SmartContextMenuBackBlurClipper? _glassBlurClipper(BuildContext context) {
    final style = widget.config.style;
    final backStyle = style.backButtonStyle;
    if (widget.glassTint == null ||
        backStyle.decoration != null ||
        backStyle.blur != SmartContextMenuBlur.strong) {
      return null;
    }
    return SmartContextMenuBackBlurClipper(
      style.borderRadius.resolve(Directionality.of(context)),
    );
  }

  Widget _buildList(SmartContextMenuBackBlurClipper? clipper) {
    if (clipper == null) return widget.list;
    return ClipPath(
      clipper: _GlassSubmenuListClipper(
        backBlurClipper: clipper,
        backItemHeight: _backItemHeight,
        backItemOverlap: _backItemOverlap,
      ),
      child: widget.list,
    );
  }

  Widget _buildBackItem(SmartContextMenuBackBlurClipper? clipper) {
    final backItem = SmartContextMenuBackItem(
      config: widget.config,
      hoverController: widget.hoverController,
      onTap: widget.onBack,
      glassTint: widget.glassTint,
      hasItemsUnderBack: _hasItemsUnderBack,
      glassBlurClipper: clipper,
    );
    if (clipper == null) return backItem;
    return WidgetSizeListener(
      onSizeChanged: _updateBackItemSize,
      child: backItem,
    );
  }

  void _updateBackItemSize(Size size) {
    if (_backItemHeight == size.height) return;
    setState(() => _backItemHeight = size.height);
  }

  bool _updateBackItem(Notification notification) {
    final metrics = switch (notification) {
      ScrollNotification(depth: 0, :final metrics) => metrics,
      ScrollMetricsNotification(depth: 0, :final metrics) => metrics,
      _ => null,
    };
    if (metrics != null) {
      final hasItemsUnderBack = metrics.pixels > metrics.minScrollExtent;
      if (hasItemsUnderBack != _hasItemsUnderBack) {
        setState(() => _hasItemsUnderBack = hasItemsUnderBack);
      }
    }
    return false;
  }
}

/// Hides scrolling content at the rim wherever the pinned filter leaves it
/// clear. Below the pinned row the list paints across its full width.
final class _GlassSubmenuListClipper extends CustomClipper<Path> {
  final SmartContextMenuBackBlurClipper backBlurClipper;
  final double backItemHeight;
  final double backItemOverlap;

  const _GlassSubmenuListClipper({
    required this.backBlurClipper,
    required this.backItemHeight,
    required this.backItemOverlap,
  });

  @override
  Path getClip(Size size) {
    final bounds = Offset.zero & size;
    final backItemBottom = (backItemHeight - backItemOverlap).clamp(
      0.0,
      size.height,
    );
    final belowBack = Rect.fromLTRB(0, backItemBottom, size.width, size.height);
    final backFilter = backBlurClipper
        .getClip(Size(size.width, backItemHeight))
        // Keep item pixels out of the filter clip's anti-aliased edge.
        .deflate(1)
        .shift(Offset(0, -backItemOverlap));
    return Path.combine(
      PathOperation.intersect,
      Path()..addRect(bounds),
      Path()
        ..addRRect(backFilter)
        ..addRect(belowBack),
    );
  }

  @override
  bool shouldReclip(_GlassSubmenuListClipper oldClipper) =>
      backItemHeight != oldClipper.backItemHeight ||
      backItemOverlap != oldClipper.backItemOverlap ||
      backBlurClipper.shouldReclip(oldClipper.backBlurClipper);
}
