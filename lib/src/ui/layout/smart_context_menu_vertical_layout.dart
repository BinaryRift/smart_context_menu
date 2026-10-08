import 'dart:math' as math;

/// Places the preview vertically and tells when the content scrolls.
///
/// The content goes from top to bottom: the header slivers, the preview,
/// the menu gap and the menu. The preview stays at the place of the widget
/// when the menu fits below it, and moves up only as far as needed.
///
/// Keeps the position between updates: by default the preview only moves
/// up, so the menu stays under the finger when it gets shorter.
final class SmartContextMenuVerticalLayout {
  /// The top of the widget on the screen.
  final double anchorTop;
  final double previewHeight;
  final double menuGap;

  /// See [SmartContextMenuConfig.moveBackDown].
  final bool moveBackDown;

  /// The height of the header slivers.
  double headerExtent = 0;

  double _screenHeight = double.infinity;
  double _topSafe = 0;
  double _bottomSafe = 0;
  double _previewTop = double.maxFinite;
  double _lastContentHeight = 0;

  SmartContextMenuVerticalLayout({
    required this.anchorTop,
    required this.previewHeight,
    required this.menuGap,
    required this.moveBackDown,
  });

  /// The top of the preview in the content, after the last [update].
  double get previewTop => _previewTop;

  /// The space above the header slivers.
  double get topPadding => _previewTop - headerExtent;

  /// The tallest menu that fits on the screen without scrolling.
  double get heightThreshold =>
      _screenHeight -
      _topSafe -
      _bottomSafe -
      headerExtent -
      previewHeight -
      menuGap;

  /// Sets the screen height and the distances to keep from its edges,
  /// including the system paddings.
  void setBounds({
    required double screenHeight,
    required double topSafe,
    required double bottomSafe,
  }) {
    _screenHeight = screenHeight;
    _topSafe = topSafe;
    _bottomSafe = bottomSafe;
  }

  /// Whether a menu of [menuHeight] makes the content scroll.
  bool isOverflowing(double menuHeight) => menuHeight > heightThreshold;

  /// Places the preview for a menu of [menuHeight].
  ///
  /// With [moveBackDown], the preview also moves back down when the menu
  /// shrinks, but not below its place on the screen, and only while the
  /// content fits without scrolling. While it scrolls, the preview only
  /// moves up: moving down would shift the scroll position under the user.
  ///
  /// The header slivers always fit above the preview: if there is no room
  /// for them, the preview moves down.
  ///
  /// Returns whether to scroll to the bottom, so the menu is seen: when the
  /// content has grown and does not fit on the screen.
  bool update(double menuHeight) {
    double targetTop = anchorTop;
    final double totalHeight = previewHeight + menuGap + menuHeight;
    final double spaceBelow = _screenHeight - targetTop - _bottomSafe;
    if (totalHeight > spaceBelow) {
      targetTop -= totalHeight - spaceBelow;
    }

    final double minTop = _topSafe + headerExtent;
    final double finalTop = math.max(targetTop, minTop);
    final bool overflows = isOverflowing(menuHeight);
    final bool canMoveDown = moveBackDown && !overflows;

    if (finalTop < _previewTop || canMoveDown) {
      _previewTop = finalTop;
    }
    _previewTop = math.max(_previewTop, minTop);

    final double contentHeight = menuHeight + headerExtent;
    final bool scrollToBottom = contentHeight > _lastContentHeight && overflows;
    _lastContentHeight = contentHeight;
    return scrollToBottom;
  }
}
