import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' show RenderMetaData, RendererBinding;
import 'package:flutter/widgets.dart';

import 'smart_context_menu_level_switcher.dart';

/// Keeps a swipe back of [SmartContextMenuLevelSwitcher] from starting on
/// [child] while [excludes] is true, so a horizontal drag that starts there
/// selects the items under the finger.
///
/// Stays in the tree when [excludes] changes, so [child] keeps its state.
final class SmartContextMenuSwipeBackExclusion extends StatelessWidget {
  // Not a Key: a MetaData with a Key marks a menu item.
  static final Object _marker = Object();

  final bool excludes;
  final Widget child;

  const SmartContextMenuSwipeBackExclusion({
    super.key,
    this.excludes = true,
    required this.child,
  });

  /// Whether a [SmartContextMenuSwipeBackExclusion] is at [position] of the
  /// view [viewId], including the gaps between its children.
  static bool isAt(Offset position, {required int viewId}) {
    final result = HitTestResult();
    RendererBinding.instance.hitTestInView(result, position, viewId);
    return result.path.any(
      (entry) =>
          entry.target is RenderMetaData &&
          (entry.target as RenderMetaData).metaData == _marker,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: excludes ? _marker : null,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

/// The swipe back of [SmartContextMenuLevelSwitcher], which does not take
/// a pointer pressed on a [SmartContextMenuSwipeBackExclusion].
final class SmartContextMenuSwipeBackRecognizer
    extends HorizontalDragGestureRecognizer {
  @override
  bool isPointerAllowed(PointerEvent event) {
    if (!super.isPointerAllowed(event)) return false;
    if (event is! PointerDownEvent) return true;
    return !SmartContextMenuSwipeBackExclusion.isAt(
      event.position,
      viewId: event.viewId,
    );
  }
}
