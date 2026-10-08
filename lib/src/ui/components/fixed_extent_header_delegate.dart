import 'package:flutter/widgets.dart';

/// Lays out [child] as a persistent header of a fixed [height].
final class FixedExtentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  FixedExtentHeaderDelegate({required this.height, required this.child});

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
  bool shouldRebuild(FixedExtentHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
