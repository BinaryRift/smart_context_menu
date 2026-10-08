import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

/// The widget the menu is attached to, in its place on the screen.
///
/// The snapshot of the preview is taken from the [RepaintBoundary] with
/// [previewKey]. While the menu is open, [child] is hidden but keeps its
/// size and state, and the snapshot flies between its place and the menu
/// with a [Hero].
final class SmartContextMenuAnchor extends StatelessWidget {
  /// The key of the [RepaintBoundary] around [child].
  final GlobalKey previewKey;

  /// The key that keeps the state of [child] when the widgets around it
  /// change.
  final GlobalKey contentKey;

  final String heroTag;

  /// Returns the snapshot of the preview.
  ///
  /// Read when the [Hero] flies too: the snapshot is set right before
  /// the menu opens, without a rebuild.
  final ValueGetter<ui.Image?> snapshot;

  /// Whether the menu is opening, open or closing.
  final bool isMenuActive;

  /// Whether the menu is open or closing.
  final bool isMenuVisible;

  final Widget child;

  const SmartContextMenuAnchor({
    super.key,
    required this.previewKey,
    required this.contentKey,
    required this.heroTag,
    required this.snapshot,
    required this.isMenuActive,
    required this.isMenuVisible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [_buildSourceContent(), _buildPhantomHero()],
    );
  }

  Widget _buildSourceContent() {
    return RepaintBoundary(
      key: previewKey,
      child: Visibility(
        visible: !isMenuVisible,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        child: KeyedSubtree(key: contentKey, child: child),
      ),
    );
  }

  Widget _buildPhantomHero() {
    if (!isMenuActive) {
      return const SizedBox.shrink();
    }

    final image = snapshot();
    return Positioned.fill(
      child: IgnorePointer(
        child: Hero(
          tag: heroTag,
          flightShuttleBuilder: _buildFlightShuttle,
          child: isMenuVisible && image != null
              ? RawImage(image: image, fit: BoxFit.fill)
              : const DecoratedBox(
                  decoration: BoxDecoration(color: Colors.transparent),
                ),
        ),
      ),
    );
  }

  Widget _buildFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final image = snapshot();
    return image != null
        ? RawImage(image: image, fit: BoxFit.fill)
        : const SizedBox.shrink();
  }
}
