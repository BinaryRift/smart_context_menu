import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lays out the cells of a row side by side in one line.
///
/// Children wrapped in [SmartContextMenuRowCell] share by their flex the
/// width left after the other children, [padding] and [childrenGap]. The
/// other children, such as separators, keep their own width. The row is as
/// wide as its constraints allow and as tall as its tallest child, and each
/// child takes the full height of the row and is clipped to its bounds.
/// The children follow the ambient [Directionality]: from right to left in
/// RTL.
///
/// The row itself is not hit: only its children are.
final class SmartContextMenuRowLayout extends MultiChildRenderObjectWidget {
  /// The padding around the children.
  final EdgeInsets padding;

  /// The gap between every two adjacent children.
  final double childrenGap;

  const SmartContextMenuRowLayout({
    super.key,
    this.padding = EdgeInsets.zero,
    this.childrenGap = 0,
    required super.children,
  }) : assert(childrenGap >= 0);

  @override
  RenderSmartContextMenuRow createRenderObject(BuildContext context) {
    return RenderSmartContextMenuRow(
      padding: padding,
      childrenGap: childrenGap,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSmartContextMenuRow renderObject,
  ) {
    renderObject
      ..padding = padding
      ..childrenGap = childrenGap
      ..textDirection = Directionality.of(context);
  }
}

/// Makes [child] of a [SmartContextMenuRowLayout] a cell that takes [flex]
/// shares of the free width.
final class SmartContextMenuRowCell
    extends ParentDataWidget<SmartContextMenuRowParentData> {
  final int flex;

  const SmartContextMenuRowCell({
    super.key,
    required this.flex,
    required super.child,
  }) : assert(flex > 0);

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData =
        renderObject.parentData! as SmartContextMenuRowParentData;
    if (parentData.flex == flex) return;
    parentData.flex = flex;
    renderObject.parent?.markNeedsLayout();
  }

  @override
  Type get debugTypicalAncestorWidgetClass => SmartContextMenuRowLayout;
}

/// The parent data of a child of [RenderSmartContextMenuRow].
final class SmartContextMenuRowParentData
    extends ContainerBoxParentData<RenderBox> {
  /// The share of the free width, or null for a child that keeps its own
  /// width.
  int? flex;
}

/// The render object of [SmartContextMenuRowLayout].
final class RenderSmartContextMenuRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SmartContextMenuRowParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          SmartContextMenuRowParentData
        > {
  RenderSmartContextMenuRow({
    required EdgeInsets padding,
    required double childrenGap,
    required TextDirection textDirection,
  }) : _padding = padding,
       _childrenGap = childrenGap,
       _textDirection = textDirection;

  EdgeInsets get padding => _padding;
  EdgeInsets _padding;
  set padding(EdgeInsets value) {
    if (value == _padding) return;
    _padding = value;
    markNeedsLayout();
  }

  double get childrenGap => _childrenGap;
  double _childrenGap;
  set childrenGap(double value) {
    if (value == _childrenGap) return;
    _childrenGap = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  final List<LayerHandle<ClipRectLayer>> _clipLayers = [];

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SmartContextMenuRowParentData) {
      child.parentData = SmartContextMenuRowParentData();
    }
  }

  static int? _flexOf(RenderBox child) =>
      (child.parentData! as SmartContextMenuRowParentData).flex;

  double get _gapsWidth => math.max(0, childCount - 1) * childrenGap;

  /// The width left for the children.
  double _innerWidth(double width) =>
      math.max(0, width - padding.horizontal - _gapsWidth);

  /// Gives the cells their share of the width left after the other
  /// children.
  ///
  /// [measure] returns the width of a child that is not a cell, given the
  /// width still left.
  List<double> _childWidths(
    double innerWidth,
    double Function(RenderBox child, double maxWidth) measure,
  ) {
    final widths = <double>[];
    var fixedWidth = 0.0;
    var totalFlex = 0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      final flex = _flexOf(child);
      if (flex == null) {
        final width = measure(child, math.max(0, innerWidth - fixedWidth));
        fixedWidth += width;
        widths.add(width);
      } else {
        totalFlex += flex;
        widths.add(0);
      }
    }
    if (totalFlex == 0) return widths;

    final freeWidth = math.max(0, innerWidth - fixedWidth);
    var index = 0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      if (_flexOf(child) case final flex?) {
        widths[index] = freeWidth * flex / totalFlex;
      }
      index++;
    }
    return widths;
  }

  /// Lays out the children with their widths and a free height, and returns
  /// the widths and the height of the tallest child.
  (List<double>, double) _measure(
    BoxConstraints constraints,
    ChildLayouter layoutChild,
  ) {
    assert(
      constraints.hasBoundedWidth,
      'A row of menu items needs a bounded width to divide it between '
      'the cells.',
    );
    final maxHeight = math.max(0.0, constraints.maxHeight - padding.vertical);
    var height = 0.0;
    final widths = _childWidths(_innerWidth(constraints.maxWidth), (
      child,
      maxWidth,
    ) {
      final size = layoutChild(
        child,
        BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      );
      height = math.max(height, size.height);
      return size.width;
    });

    var index = 0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      final width = widths[index++];
      if (_flexOf(child) == null) continue;
      final size = layoutChild(
        child,
        BoxConstraints(minWidth: width, maxWidth: width, maxHeight: maxHeight),
      );
      height = math.max(height, size.height);
    }
    return (widths, height);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final (_, height) = _measure(constraints, ChildLayoutHelper.dryLayoutChild);
    return constraints.constrain(
      Size(constraints.maxWidth, height + padding.vertical),
    );
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    final (widths, tallest) = _measure(
      constraints,
      ChildLayoutHelper.layoutChild,
    );
    size = constraints.constrain(
      Size(constraints.maxWidth, tallest + padding.vertical),
    );

    // The second layout stretches the children to the height of the row.
    // A minimum height instead of an exact one keeps the children from
    // becoming relayout boundaries, so the row follows their new height
    // when their content changes.
    final height = math.max(0.0, size.height - padding.vertical);
    final maxHeight = math.max(
      height,
      constraints.maxHeight - padding.vertical,
    );
    final isLtr = textDirection == TextDirection.ltr;
    var x = isLtr ? padding.left : size.width - padding.right;
    var index = 0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      final width = widths[index++];
      child.layout(
        BoxConstraints(
          minWidth: width,
          maxWidth: width,
          minHeight: height,
          maxHeight: maxHeight,
        ),
        parentUsesSize: true,
      );
      final parentData = child.parentData! as SmartContextMenuRowParentData;
      parentData.offset = Offset(isLtr ? x : x - width, padding.top);
      x += isLtr ? width + childrenGap : -(width + childrenGap);
    }
  }

  double _intrinsicWidth(
    double height,
    double Function(RenderBox child, double height) measure,
  ) {
    final childHeight = math.max(0.0, height - padding.vertical);
    var fixedWidth = 0.0;
    var totalFlex = 0;
    var widthPerFlex = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      final width = measure(child, childHeight);
      if (_flexOf(child) case final flex?) {
        totalFlex += flex;
        widthPerFlex = math.max(widthPerFlex, width / flex);
      } else {
        fixedWidth += width;
      }
    }
    return padding.horizontal +
        _gapsWidth +
        fixedWidth +
        widthPerFlex * totalFlex;
  }

  double _intrinsicHeight(
    double width,
    double Function(RenderBox child, double width) measure,
  ) {
    final widths = _childWidths(
      _innerWidth(width),
      (child, maxWidth) =>
          math.min(child.getMaxIntrinsicWidth(double.infinity), maxWidth),
    );
    var height = 0.0;
    var index = 0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      height = math.max(height, measure(child, widths[index++]));
    }
    return height + padding.vertical;
  }

  @override
  double computeMinIntrinsicWidth(double height) => _intrinsicWidth(
    height,
    (child, height) => child.getMinIntrinsicWidth(height),
  );

  @override
  double computeMaxIntrinsicWidth(double height) => _intrinsicWidth(
    height,
    (child, height) => child.getMaxIntrinsicWidth(height),
  );

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(
    width,
    (child, width) => child.getMinIntrinsicHeight(width),
  );

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(
    width,
    (child, width) => child.getMaxIntrinsicHeight(width),
  );

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  Rect _clipOf(RenderBox child) {
    final offset = (child.parentData! as SmartContextMenuRowParentData).offset;
    return (offset & child.size).intersect(Offset.zero & size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var index = 0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      if (index == _clipLayers.length) _clipLayers.add(LayerHandle());
      final layer = _clipLayers[index++];
      final clip = _clipOf(child);
      if (clip.isEmpty) {
        layer.layer = null;
        continue;
      }
      final paintedChild = child;
      final childOffset =
          (child.parentData! as SmartContextMenuRowParentData).offset;
      layer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        clip,
        (context, offset) =>
            context.paintChild(paintedChild, offset + childOffset),
        oldLayer: layer.layer,
      );
    }
    while (_clipLayers.length > index) {
      _clipLayers.removeLast().layer = null;
    }
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) =>
      child is RenderBox ? _clipOf(child) : null;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void dispose() {
    for (final layer in _clipLayers) {
      layer.layer = null;
    }
    _clipLayers.clear();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<EdgeInsets>('padding', padding))
      ..add(DoubleProperty('childrenGap', childrenGap))
      ..add(EnumProperty<TextDirection>('textDirection', textDirection));
  }
}
