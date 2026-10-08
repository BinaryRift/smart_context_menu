import 'package:flutter/widgets.dart';

/// Lays out the preview as a sliver of a fixed [height].
final class PreviewSliverDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  PreviewSliverDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(PreviewSliverDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
