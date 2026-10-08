import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_header_details.dart';
import '../layout/smart_context_menu_horizontal_layout.dart';
import 'sliver_extent_listener.dart';
import 'sliver_paint_offset.dart';
import 'smart_context_menu_motion.dart';

/// The slivers built by [builder] above the preview.
///
/// They have the horizontal padding of the preview, move with it by
/// [motion], fade with [animation] if [fade] is true and report their
/// height to [onExtentChanged].
final class SmartContextMenuHeader extends StatelessWidget {
  final SmartContextMenuHeaderBuilder builder;
  final SmartContextMenuHorizontalLayout layout;
  final Animation<double> animation;
  final bool fade;
  final ValueListenable<Offset> motion;
  final Future<void> Function() close;
  final ValueChanged<double> onExtentChanged;

  /// The key of the group of the built slivers.
  final GlobalKey groupKey;

  const SmartContextMenuHeader({
    super.key,
    required this.builder,
    required this.layout,
    required this.animation,
    required this.fade,
    required this.motion,
    required this.close,
    required this.onExtentChanged,
    required this.groupKey,
  });

  @override
  Widget build(BuildContext context) {
    final header = SmartContextMenuHeaderDetails(
      alignment: layout.alignment,
      animation: animation,
      close: close,
    );

    final Widget slivers = SliverPadding(
      padding: layout.padding,
      sliver: SliverMainAxisGroup(
        key: groupKey,
        slivers: builder(context, header),
      ),
    );

    return SliverExtentListener(
      onExtentChanged: onExtentChanged,
      sliver: SmartContextMenuMotion(
        motion: motion,
        builder: (context, offset, child) {
          return SliverPaintOffset(offset: offset, sliver: child);
        },
        child: fade
            ? SliverFadeTransition(opacity: animation, sliver: slivers)
            : slivers,
      ),
    );
  }
}
