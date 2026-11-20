import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/gestures.dart' show kPrimaryButton;
import 'package:flutter/widgets.dart';

import '../extensions/render_object_ext.dart';
import '../state/smart_context_menu_hover_controller.dart';

/// Tracks presses over [child] and reports the item under the pressed
/// pointer to [hoverController]. Items report the cursor hover themselves.
///
/// Only a touch, a stylus or the primary mouse button selects items.
///
/// During a press, scrolling inside [child] or swiping back a level
/// (see [isSwiping]) blocks drag selection until the pointer is lifted.
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
  int? _pointer;
  bool _isMousePress = false;
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
    _press(null);
  }

  void _onPointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      if (event.buttons & kPrimaryButton != 0) _handlePointerDown(event);
      return;
    }
    if (event.pointer != _pointer) return;
    if (event is PointerMoveEvent) {
      _handlePointerMove(event);
    } else if (event is PointerUpEvent) {
      _handlePointerReset(isCanceled: false);
    } else if (event is PointerCancelEvent) {
      _handlePointerReset(isCanceled: true);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pointer = event.pointer;
    _startPosition = event.position;
    _isMousePress = event.kind == PointerDeviceKind.mouse;
    _isSelectionBlocked = false;
    _updatePressedItem(event.position);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final startPosition = _startPosition;
    if (startPosition == null) return;
    _updatePressedItem(event.position);
    widget.onDrag(event.position - startPosition);
  }

  /// A canceled pointer, for example interrupted by the system,
  /// only clears the highlight and does not tap the item under it.
  void _handlePointerReset({required bool isCanceled}) {
    _pointer = null;
    if (!isCanceled && _hoverController.value != null && !_isSelectionBlocked) {
      _hoverController.setReleased();
    }

    Future.microtask(() {
      _hoverController.endPress();
      _startPosition = null;
      _isMousePress = false;
      _isSelectionBlocked = false;
      widget.onRelease();
    });
  }

  void _updatePressedItem(Offset globalPosition) {
    if (_isSelectionBlocked) {
      _press(null);
      return;
    }
    _press(context.findRenderObject()?.findMenuItemKeyAt(globalPosition));
  }

  void _press(Key? key) => _hoverController.press(key, isMouse: _isMousePress);
}
