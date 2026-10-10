import 'package:flutter/cupertino.dart';

const _size = 40.0;

/// How long a circle fades out after its finger is lifted, so even a quick
/// tap is seen in a screen recording.
const _fadeDuration = Duration(milliseconds: 300);

/// Shows a circle under every finger on top of [child], menus included,
/// so screen recordings show the touches.
final class TouchIndicator extends StatefulWidget {
  final bool enabled;
  final Widget child;

  const TouchIndicator({super.key, required this.enabled, required this.child});

  @override
  State<TouchIndicator> createState() => _TouchIndicatorState();
}

final class _TouchIndicatorState extends State<TouchIndicator> {
  /// The touches by their pointer.
  final _touches = <int, _Touch>{};

  @override
  void didUpdateWidget(TouchIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _touches.clear();
  }

  @override
  Widget build(BuildContext context) {
    // The same tree whether enabled or not, so turning the circles on does
    // not rebuild the app below. Only listens: the touches still reach it.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onMove,
      onPointerMove: _onMove,
      onPointerUp: _onLift,
      onPointerCancel: _onLift,
      child: Stack(
        children: [
          widget.child,
          for (final MapEntry(key: pointer, value: touch) in _touches.entries)
            Positioned(
              key: ValueKey(pointer),
              left: touch.position.dx - _size / 2,
              top: touch.position.dy - _size / 2,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: touch.isDown ? 1 : 0,
                  duration: _fadeDuration,
                  child: const _TouchCircle(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onMove(PointerEvent event) {
    if (!widget.enabled) return;
    setState(() => _touches[event.pointer] = _Touch(event.localPosition));
  }

  Future<void> _onLift(PointerEvent event) async {
    final touch = _touches[event.pointer];
    if (touch == null) return;
    setState(() => touch.isDown = false);
    await Future<void>.delayed(_fadeDuration);
    if (mounted) setState(() => _touches.remove(event.pointer));
  }
}

final class _Touch {
  final Offset position;
  bool isDown = true;

  _Touch(this.position);
}

/// A light gray circle with a thin darker edge, as the touches of the iOS
/// Simulator, seen on light and dark screens.
final class _TouchCircle extends StatelessWidget {
  const _TouchCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xCCCCCCCC),
        border: Border.all(color: const Color(0x33000000)),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 2)],
      ),
    );
  }
}
