import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_header_details.dart';
import '../layout/smart_context_menu_horizontal_layout.dart';
import 'sliver_extent_listener.dart';

/// The slivers built by [builder] above the preview.
///
/// They have the horizontal padding of the preview, fade with [animation]
/// and report their height to [onExtentChanged].
final class SmartContextMenuHeader extends StatelessWidget {
  final SmartContextMenuHeaderBuilder builder;
  final SmartContextMenuHorizontalLayout layout;
  final Animation<double> animation;
  final Future<void> Function() close;
  final ValueChanged<double> onExtentChanged;

  /// The key of the group of the built slivers.
  final GlobalKey groupKey;

  const SmartContextMenuHeader({
    super.key,
    required this.builder,
    required this.layout,
    required this.animation,
    required this.close,
    required this.onExtentChanged,
    required this.groupKey,
  });

  @override
  Widget build(BuildContext context) {
    final header = SmartContextMenuHeaderDetails(
      alignment: layout.alignment,
      close: close,
    );

    return SliverExtentListener(
      onExtentChanged: onExtentChanged,
      sliver: SliverFadeTransition(
        opacity: animation,
        sliver: SliverPadding(
          padding: layout.padding,
          sliver: SliverMainAxisGroup(
            key: groupKey,
            slivers: builder(context, header),
          ),
        ),
      ),
    );
  }
}
