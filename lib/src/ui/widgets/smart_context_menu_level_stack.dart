import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lays out menu levels on top of each other, aligned to the top.
///
/// Each level keeps its own height. The stack is as tall as the average
/// of the level heights weighted by [presences], so the menu height
/// follows the level transitions. Levels taller than the stack overflow it
/// and are clipped by the menu.
final class SmartContextMenuLevelStack extends MultiChildRenderObjectWidget {
  /// The weight of each child height, in the order of the children.
  final List<double> presences;

  const SmartContextMenuLevelStack({
    super.key,
    required this.presences,
    required super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSmartContextMenuLevelStack(presences);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSmartContextMenuLevelStack renderObject,
  ) {
    renderObject.presences = presences;
  }
}

final class _LevelStackParentData extends ContainerBoxParentData<RenderBox> {}

/// The render object of [SmartContextMenuLevelStack].
final class RenderSmartContextMenuLevelStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _LevelStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _LevelStackParentData> {
  List<double> _presences;

  RenderSmartContextMenuLevelStack(this._presences);

  List<double> get presences => _presences;

  set presences(List<double> value) {
    if (listEquals(_presences, value)) return;
    _presences = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _LevelStackParentData) {
      child.parentData = _LevelStackParentData();
    }
  }

  BoxConstraints _childConstraints(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.minWidth,
      maxWidth: constraints.maxWidth,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  void performLayout() {
    final childConstraints = _childConstraints(constraints);
    final sizes = <Size>[];
    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(childConstraints, parentUsesSize: true);
      sizes.add(child.size);
    }
    size = _sizeFor(sizes, constraints);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childConstraints = _childConstraints(constraints);
    return _sizeFor([
      for (var child = firstChild; child != null; child = childAfter(child))
        child.getDryLayout(childConstraints),
    ], constraints);
  }

  Size _sizeFor(List<Size> sizes, BoxConstraints constraints) {
    assert(sizes.length == _presences.length);
    if (sizes.isEmpty) return constraints.smallest;

    var width = 0.0;
    var weightedHeight = 0.0;
    var totalPresence = 0.0;
    for (var i = 0; i < sizes.length; i++) {
      final presence = _presences[i].clamp(0.0, 1.0);
      width = width > sizes[i].width ? width : sizes[i].width;
      weightedHeight += sizes[i].height * presence;
      totalPresence += presence;
    }

    // The last child is the current level.
    final height = totalPresence == 0
        ? sizes.last.height
        : weightedHeight / totalPresence;
    return constraints.constrain(Size(width, height));
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _maxOfChildren((child) => child.getMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _maxOfChildren((child) => child.getMaxIntrinsicWidth(height));

  @override
  double computeMinIntrinsicHeight(double width) =>
      _maxOfChildren((child) => child.getMinIntrinsicHeight(width));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _maxOfChildren((child) => child.getMaxIntrinsicHeight(width));

  double _maxOfChildren(double Function(RenderBox child) measure) {
    var result = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      final value = measure(child);
      if (value > result) result = value;
    }
    return result;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
