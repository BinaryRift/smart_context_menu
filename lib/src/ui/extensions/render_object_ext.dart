import 'package:flutter/rendering.dart';

extension SmartContextMenuItemHitTest on RenderObject {
  /// Returns the key of the topmost menu item under [globalPosition]
  /// inside this render object, or `null` if there is none.
  ///
  /// Items are found by their [RenderMetaData] with a [Key].
  /// Returns `null` when an interactive child of the item is under
  /// the pointer, so the child handles the gesture itself.
  ///
  /// Walks the render tree instead of using `hitTest`, so render objects
  /// that ignore pointers, such as the invisible back placeholder, are found
  /// too. Painted-last children are checked first.
  Key? findMenuItemKeyAt(Offset globalPosition) {
    final item = _findTopmost(globalPosition, _isItem);
    if (item == null) return null;

    RenderBox? interactiveChild;
    item.visitChildren((child) {
      interactiveChild ??= child._findTopmost(globalPosition, _isInteractive);
    });
    if (interactiveChild != null) return null;

    return (item as RenderMetaData).metaData as Key;
  }

  static bool _isItem(RenderBox object) =>
      object is RenderMetaData && object.metaData is Key;

  static bool _isInteractive(RenderBox object) =>
      object is RenderPointerListener ||
      object is RenderSemanticsGestureHandler;

  RenderBox? _findTopmost(
    Offset globalPosition,
    bool Function(RenderBox object) test,
  ) {
    final object = this;
    if (object is! RenderBox) {
      RenderBox? found;
      visitChildren((child) {
        found ??= child._findTopmost(globalPosition, test);
      });
      return found;
    }

    if (!object.hasSize) return null;

    final Rect rect = object.localToGlobal(Offset.zero) & object.size;

    // Pointer is outside the bounds: skip the whole subtree.
    if (!rect.contains(globalPosition)) return null;

    if (test(object)) return object;

    final List<RenderObject> children = [];
    visitChildren(children.add);

    for (final child in children.reversed) {
      final found = child._findTopmost(globalPosition, test);
      if (found != null) return found;
    }

    return null;
  }
}

extension SmartContextMenuContentHitTest on RenderObject {
  /// Whether a hit test at [globalPosition] in the view [viewId] hits this
  /// render object.
  ///
  /// Empty space inside it does not count: a render object is in the hit
  /// test path only if it or one of its children is hit.
  bool isHitAt(Offset globalPosition, {required int viewId}) {
    final result = HitTestResult();
    RendererBinding.instance.hitTestInView(result, globalPosition, viewId);
    return result.path.any((entry) => entry.target == this);
  }
}

extension SmartContextMenuBoxBounds on RenderBox {
  /// Whether [globalPosition] is inside the paint bounds of this box.
  bool containsGlobal(Offset globalPosition) {
    return paintBounds.contains(globalToLocal(globalPosition));
  }
}
