import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Paints [sliver] moved by [offset], like [Transform.translate] does for
/// a box, and hit tests it where it is painted.
///
/// Does not change the layout. Works in a vertical scroll view that goes
/// down. Only the part inside the layout extent of the sliver can be hit:
/// the offset is meant to be small and short-lived.
final class SliverPaintOffset extends SingleChildRenderObjectWidget {
  final Offset offset;

  const SliverPaintOffset({
    super.key,
    required this.offset,
    required Widget sliver,
  }) : super(child: sliver);

  @override
  RenderSliverPaintOffset createRenderObject(BuildContext context) {
    return RenderSliverPaintOffset(offset: offset);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverPaintOffset renderObject,
  ) {
    renderObject.offset = offset;
  }
}

final class RenderSliverPaintOffset extends RenderProxySliver {
  Offset _offset;

  RenderSliverPaintOffset({required this._offset});

  Offset get offset => _offset;

  set offset(Offset value) {
    if (value == _offset) return;
    _offset = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset + _offset);
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    transform.translateByDouble(_offset.dx, _offset.dy, 0, 1);
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    final RenderSliver? child = this.child;
    if (child == null || child.geometry!.hitTestExtent <= 0) return false;

    return result.addWithAxisOffset(
      paintOffset: _offset,
      mainAxisOffset: _offset.dy,
      crossAxisOffset: _offset.dx,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
      hitTest: child.hitTest,
    );
  }
}
