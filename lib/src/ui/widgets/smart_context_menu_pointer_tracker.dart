import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

import '../extensions/render_object_ext.dart';
import '../state/smart_context_menu_hover_controller.dart';

/// Tracks the pointer over [child] and reports the item under it
/// to [hoverController].
///
/// Once a scrollable inside [child] scrolls or a level is swiped back
/// (see [isSwiping]), the gesture no longer hovers or selects an item
/// until the pointer is lifted.
final class SmartContextMenuPointerTracker extends StatefulWidget {
  final SmartContextMenuHoverController hoverController;

  /// Whether a menu level is being swiped back.
  final ValueListenable<bool> isSwiping;

  /// Called on pointer move with the offset from the pointer-down position.
  final ValueChanged<Offset> onDrag;

  /// Called after the pointer is lifted or canceled.
  final VoidCallback onRelease;

  final Widget child;

  const SmartContextMenuPointerTracker({
    super.key,
    required this.hoverController,
    required this.isSwiping,
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
  bool _isSelectionBlocked = false;

  SmartContextMenuHoverController get _hoverController =>
      widget.hoverController;

  @override
  void initState() {
    super.initState();
    widget.isSwiping.addListener(_onSwipeChanged);
  }

  @override
  void didUpdateWidget(SmartContextMenuPointerTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSwiping != oldWidget.isSwiping) {
      oldWidget.isSwiping.removeListener(_onSwipeChanged);
      widget.isSwiping.addListener(_onSwipeChanged);
    }
  }

  @override
  void dispose() {
    widget.isSwiping.removeListener(_onSwipeChanged);
    super.dispose();
  }

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
    if (notification is ScrollStartNotification) _blockSelection();
    return false;
  }

  void _onSwipeChanged() {
    if (widget.isSwiping.value) _blockSelection();
  }

  void _blockSelection() {
    if (_startPosition == null) return;
    _isSelectionBlocked = true;
    if (_hoverController.value != null) _hoverController.update(null);
  }

  void _onPointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      _handlePointerDown(event);
    } else if (event is PointerMoveEvent) {
      _handlePointerMove(event);
    } else if (event is PointerUpEvent) {
      _handlePointerReset(isCanceled: false);
    } else if (event is PointerCancelEvent) {
      _handlePointerReset(isCanceled: true);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    _startPosition = event.position;
    _isSelectionBlocked = false;
    _updateHoveredItem(event.position);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final startPosition = _startPosition;
    if (startPosition == null) return;
    _updateHoveredItem(event.position);
    widget.onDrag(event.position - startPosition);
  }

  /// A canceled pointer, for example interrupted by the system,
  /// only clears the highlight and does not tap the item under it.
  void _handlePointerReset({required bool isCanceled}) {
    if (!isCanceled && _hoverController.value != null && !_isSelectionBlocked) {
      _hoverController.setReleased();
    }

    Future.microtask(() {
      _hoverController.update(null);
      _startPosition = null;
      widget.onRelease();
    });
  }

  void _updateHoveredItem(Offset globalPosition) {
    if (_isSelectionBlocked) {
      if (_hoverController.value != null) _hoverController.update(null);
      return;
    }

    final key = context.findRenderObject()?.findMenuItemKeyAt(globalPosition);
    if (_hoverController.value != key) {
      _hoverController.update(key);
    }
  }
}
