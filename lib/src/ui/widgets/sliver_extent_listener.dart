import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Reports the scroll extent of [sliver] after each frame in which it
/// changes, like [WidgetSizeListener] does for a box.
final class SliverExtentListener extends SingleChildRenderObjectWidget {
  final ValueChanged<double> onExtentChanged;

  const SliverExtentListener({
    super.key,
    required this.onExtentChanged,
    required Widget sliver,
  }) : super(child: sliver);

  @override
  RenderSliverExtentListener createRenderObject(BuildContext context) {
    return RenderSliverExtentListener(onExtentChanged: onExtentChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverExtentListener renderObject,
  ) {
    renderObject.onExtentChanged = onExtentChanged;
  }
}

final class RenderSliverExtentListener extends RenderProxySliver {
  ValueChanged<double> onExtentChanged;
  double? _lastExtent;

  RenderSliverExtentListener({required this.onExtentChanged});

  @override
  void performLayout() {
    super.performLayout();
    final double extent = geometry!.scrollExtent;
    if (extent == _lastExtent) return;

    _lastExtent = extent;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached && _lastExtent == extent) onExtentChanged(extent);
    });
  }
}
