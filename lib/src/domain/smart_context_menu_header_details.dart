import 'package:flutter/widgets.dart'
    show Alignment, Animation, BuildContext, Widget;
import 'package:meta/meta.dart' show internal;

/// Builds the slivers shown above the preview of an open
/// [SmartContextMenu].
///
/// ```dart
/// headerSliversBuilder: (context, header) => [
///   SliverToBoxAdapter(
///     child: Align(
///       alignment: header.alignment,
///       child: ReactionsBar(
///         onSelected: (reaction) async {
///           await header.close();
///           react(reaction);
///         },
///       ),
///     ),
///   ),
/// ],
/// ```
typedef SmartContextMenuHeaderBuilder =
    List<Widget> Function(
      BuildContext context,
      SmartContextMenuHeaderDetails header,
    );

/// What the slivers above the preview get from the open menu.
///
/// Passed to [SmartContextMenuHeaderBuilder].
final class SmartContextMenuHeaderDetails {
  /// How the preview and the menu are aligned horizontally:
  /// [Alignment.topLeft], [Alignment.topCenter] or [Alignment.topRight],
  /// depending on where the widget is on the screen.
  ///
  /// The slivers have the same horizontal padding as the preview, so
  /// `Align(alignment: alignment)` puts a widget at the edge of the preview.
  final Alignment alignment;

  /// Runs from 0 to 1 as the menu opens and back to 0 as it closes.
  ///
  /// Use it to animate the slivers with the menu, for example to scale
  /// a reactions bar from the edge of the preview:
  ///
  /// ```dart
  /// ScaleTransition(
  ///   scale: header.animation.drive(CurveTween(curve: Curves.easeOutBack)),
  ///   alignment: Alignment(header.alignment.x, 1),
  ///   child: ReactionsBar(onSelected: react),
  /// )
  /// ```
  ///
  /// Prefer `drive` to [CurvedAnimation]: the builder runs on every rebuild,
  /// and a [CurvedAnimation] created there is never disposed.
  ///
  /// The slivers also fade with the menu unless
  /// [SmartContextMenu.fadeHeaderSlivers] is false.
  final Animation<double> animation;

  final Future<void> Function() _close;

  @internal
  const SmartContextMenuHeaderDetails({
    required this.alignment,
    required this.animation,
    required this._close,
  });

  /// Closes the menu.
  ///
  /// Completes halfway through the closing animation, as an item that
  /// closes on tap does, so an action started after it is seen as the menu
  /// closes. Does nothing if the menu is already closing.
  Future<void> close() => _close();
}
