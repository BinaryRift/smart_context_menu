import 'package:flutter/widgets.dart';

import '../extensions/render_object_ext.dart';
import '../state/smart_context_menu_hover_controller.dart';

/// Tracks the pointer over [child] and reports the item under it
/// to [hoverController].
///
/// Once a scrollable inside [child] scrolls, the gesture no longer hovers
/// or selects an item until the pointer is lifted.
final class SmartContextMenuPointerTracker extends StatefulWidget {
  final SmartContextMenuHoverController hoverController;

  /// Called on pointer move with the offset from the pointer-down position.
  final ValueChanged<Offset> onDrag;

  /// Called after the pointer is lifted or canceled.
  final VoidCallback onRelease;

  final Widget child;

  const SmartContextMenuPointerTracker({
    super.key,
    required this.hoverController,
    required this.onDrag,
    required this.onRelease,
    required this.child,
  });

  @override
  State<SmartContextMenuPointerTracker> createState() =>
      _SmartContextMenuPointerTrackerState();
}

final class _SmartContextMenuPointerTrackerState
    extends State<SmartContextMenuPointerTracker> {
  Offset? _startPosition;
  bool _didScroll = false;

  SmartContextMenuHoverController get _hoverController =>
      widget.hoverController;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: Listener(
        onPointerDown: _onPointerEvent,
        onPointerMove: _onPointerEvent,
        onPointerUp: _onPointerEvent,
        onPointerCancel: _onPointerEvent,
        child: widget.child,
      ),
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification && _startPosition != null) {
      _didScroll = true;
      if (_hoverController.value != null) _hoverController.update(null);
    }
    return false;
  }

  void _onPointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      _handlePointerDown(event);
    } else if (event is PointerMoveEvent) {
      _handlePointerMove(event);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _handlePointerReset();
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    _startPosition = event.position;
    _didScroll = false;
    _updateHoveredItem(event.position);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final startPosition = _startPosition;
    if (startPosition == null) return;
    _updateHoveredItem(event.position);
    widget.onDrag(event.position - startPosition);
  }

  void _handlePointerReset() {
    if (_hoverController.value != null && !_didScroll) {
      _hoverController.setReleased();
    }

    Future.microtask(() {
      _hoverController.update(null);
      _startPosition = null;
      widget.onRelease();
    });
  }

  void _updateHoveredItem(Offset globalPosition) {
    if (_didScroll) {
      if (_hoverController.value != null) _hoverController.update(null);
      return;
    }

    final key = context.findRenderObject()?.findMenuItemKeyAt(globalPosition);
    if (_hoverController.value != key) {
      _hoverController.update(key);
    }
  }
}
