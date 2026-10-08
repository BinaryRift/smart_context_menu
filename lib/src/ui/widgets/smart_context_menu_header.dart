import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_header_details.dart';
import '../layout/smart_context_menu_horizontal_layout.dart';
import 'sliver_extent_listener.dart';
import 'sliver_paint_offset.dart';
import 'smart_context_menu_motion.dart';

/// Builds the slivers from [builder] for the scroll view above the preview.
///
/// Each sliver gets the horizontal padding of the preview, moves with it by
/// [motion], fades with [animation] if [fade] is true and reports its
/// height to [onExtentChanged].
///
/// The slivers are not grouped: a [PinnedHeaderSliver] stays pinned only
/// as a direct child of the scroll view.
final class SmartContextMenuHeader {
  final SmartContextMenuHeaderBuilder builder;
  final SmartContextMenuHorizontalLayout layout;
  final Animation<double> animation;
  final bool fade;
  final ValueListenable<Offset> motion;
  final Future<void> Function() close;

  /// Called with the index of a sliver and its new height.
  final void Function(int index, double extent) onExtentChanged;

  /// Returns the key of the sliver at an index.
  final GlobalKey Function(int index) keyOf;

  const SmartContextMenuHeader({
    required this.builder,
    required this.layout,
    required this.animation,
    required this.fade,
    required this.motion,
    required this.close,
    required this.onExtentChanged,
    required this.keyOf,
  });

  List<Widget> build(BuildContext context) {
    final header = SmartContextMenuHeaderDetails(
      alignment: layout.alignment,
      animation: animation,
      close: close,
    );
    final slivers = builder(context, header);

    return [for (var i = 0; i < slivers.length; i++) _wrap(i, slivers[i])];
  }

  Widget _wrap(int index, Widget sliver) {
    final Widget padded = SliverPadding(
      padding: layout.padding,
      sliver: sliver,
    );

    return SliverExtentListener(
      key: keyOf(index),
      onExtentChanged: (extent) => onExtentChanged(index, extent),
      sliver: SmartContextMenuMotion(
        motion: motion,
        builder: (context, offset, child) {
          return SliverPaintOffset(offset: offset, sliver: child);
        },
        child: fade
            ? SliverFadeTransition(opacity: animation, sliver: padded)
            : padded,
      ),
    );
  }
}
