import 'package:flutter/gestures.dart'
    show
        GestureBinding,
        LongPressGestureRecognizer,
        TapGestureRecognizer,
        kSecondaryButton;
import 'package:flutter/widgets.dart';

import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_scales.dart';

/// Shrinks [child] while it is pressed and calls [onLongPress] after
/// a long press, once [child] is back to its size. A secondary click calls
/// [onSecondaryClick] immediately, without shrinking [child]. Of nested
/// detectors, only the innermost one handles a press.
///
/// The long press wins over the gestures of [child]. When disabled,
/// [child] is returned as is.
final class SmartContextMenuPressDetector extends StatefulWidget {
  /// Whether presses are handled.
  final bool enabled;

  /// Whether the menu is opening, open or closing. Presses are ignored then.
  final bool isMenuActive;

  final VoidCallback onLongPress;
  final VoidCallback onSecondaryClick;
  final Widget child;

  const SmartContextMenuPressDetector({
    super.key,
    required this.enabled,
    required this.isMenuActive,
    required this.onLongPress,
    required this.onSecondaryClick,
    required this.child,
  });

  @override
  State<SmartContextMenuPressDetector> createState() =>
      _SmartContextMenuPressDetectorState();
}

final class _SmartContextMenuPressDetectorState
    extends State<SmartContextMenuPressDetector>
    with SingleTickerProviderStateMixin {
  static const Duration _pressDuration = MotionDurations.medium;

  /// The pointer-down event that a detector already took. Listeners get
  /// the event from the innermost detector outward, so the outer ones
  /// skip it.
  static PointerEvent? _takenDown;

  late final LongPressGestureRecognizer _longPressRecognizer;
  late final TapGestureRecognizer _tapRecognizer;
  late final AnimationController _scaleController;
  late final CurvedAnimation _scaleCurve;
  late final Animation<double> _scaleAnimation;
  int? _activePointer;

  /// Whether this detector took the current press, see [_takenDown].
  bool _isPressTaken = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupRecognizers();
  }

  @override
  void didUpdateWidget(covariant SmartContextMenuPressDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncRecognizers();
  }

  @override
  void dispose() {
    _longPressRecognizer.dispose();
    _scaleCurve.dispose();
    _scaleController.dispose();
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerCancel: (_) {
        if (!widget.isMenuActive) _scaleController.reverse();
      },
      child: RawGestureDetector(
        behavior: HitTestBehavior.translucent,
        gestures: {
          LongPressGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                () => _longPressRecognizer,
                (instance) {},
              ),
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                () => _tapRecognizer,
                (instance) {},
              ),
        },
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
      ),
    );
  }

  void _setupRecognizers() {
    _longPressRecognizer = LongPressGestureRecognizer(
      debugOwner: this,
      duration: _pressDuration,
    );

    _tapRecognizer = TapGestureRecognizer();
    _syncRecognizers();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      vsync: this,
      duration: _pressDuration,
    );

    _scaleCurve = CurvedAnimation(
      parent: _scaleController,
      curve: MotionCurves.standard,
    );
    _scaleAnimation = Tween<double>(
      begin: MotionScale.none.value,
      end: MotionScale.pressed.value,
    ).animate(_scaleCurve);
  }

  void _syncRecognizers() {
    final enabled = widget.enabled;

    _longPressRecognizer.onLongPress = enabled ? _handleLongPress : null;
    _tapRecognizer.onTapDown = enabled ? (_) => _startScale() : null;
    _tapRecognizer.onTapUp = enabled ? (_) => _stopScale() : null;
    _tapRecognizer.onTapCancel = enabled ? _stopScale : null;

    if (!enabled) {
      _scaleController.reset();
      return;
    }

    if (!widget.isMenuActive && _scaleController.value != 0) {
      _scaleController.reset();
    }
  }

  void _startScale() {
    if (_isPressTaken && !widget.isMenuActive) _scaleController.forward();
  }

  void _stopScale() {
    if (widget.isMenuActive) return;
    _scaleController.animateTo(0, duration: MotionDurations.ultraFast);
  }

  Future<void> _handleLongPress() async {
    if (widget.isMenuActive) return;

    _interruptInternalGestures();

    await _scaleController.animateTo(0, duration: MotionDurations.fast);

    if (mounted) widget.onLongPress();
  }

  void _interruptInternalGestures() {
    if (_activePointer != null) {
      GestureBinding.instance.gestureArena.close(_activePointer!);
      GestureBinding.instance.gestureArena.sweep(_activePointer!);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointer = event.pointer;
    final original = event.original ?? event;
    _isPressTaken = !widget.isMenuActive && !identical(original, _takenDown);
    if (!_isPressTaken) return;
    _takenDown = original;
    if (event.buttons == kSecondaryButton) widget.onSecondaryClick();
  }
}
