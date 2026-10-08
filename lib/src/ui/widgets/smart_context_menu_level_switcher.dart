import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../core/ui/gestures/gesture_thresholds.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_slides.dart';
import '../../core/ui/motion/transitions/fade_slide_transition.dart';
import '../state/smart_context_menu_level_entry.dart';

/// Switches menu levels: a submenu slides in from the right and pushes
/// the current level to the left; going back, the parent slides in from
/// the left and pushes the submenu to the right.
///
/// With [enableSwipeBack] and a [previous] level, swiping right drags
/// the current level away and reveals [previous]. If the swipe goes far
/// or fast enough, [onSwipeBack] is called once released.
///
/// Give each level its own key, so a new level is animated in.
final class SmartContextMenuLevelSwitcher extends StatefulWidget {
  /// Whether [child] is a submenu opened from the current level.
  final bool isForward;

  /// The parent level of [child], shown under it while swiping back.
  final Widget? previous;

  final bool enableSwipeBack;

  /// Set to true while a swipe back follows the finger.
  final ValueNotifier<bool>? isSwiping;

  /// Called when a swipe back is released past the thresholds. Should
  /// replace [child] with [previous].
  final VoidCallback onSwipeBack;

  final Widget child;

  const SmartContextMenuLevelSwitcher({
    super.key,
    required this.isForward,
    required this.child,
    required this.onSwipeBack,
    this.previous,
    this.enableSwipeBack = false,
    this.isSwiping,
  });

  @override
  State<SmartContextMenuLevelSwitcher> createState() =>
      _SmartContextMenuLevelSwitcherState();
}

final class _SmartContextMenuLevelSwitcherState
    extends State<SmartContextMenuLevelSwitcher>
    with TickerProviderStateMixin {
  late SmartContextMenuLevelEntry _current;
  final List<SmartContextMenuLevelEntry> _leaving = [];

  /// The parent level revealed by a swipe back.
  SmartContextMenuLevelEntry? _swipeParent;
  bool _isTracking = false;
  bool _isSettling = false;
  double _swipeProgress = 0;
  double _swipeWidth = 0;

  bool get _canSwipe => widget.enableSwipeBack && widget.previous != null;

  @override
  void initState() {
    super.initState();
    _current = _createEntry(
      widget.child,
      enterFrom: MotionSlide.rightHalf.offset,
    )..controller.value = 1;
  }

  @override
  void didUpdateWidget(SmartContextMenuLevelSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = widget.previous;
    final swipeParent = _swipeParent;
    if (swipeParent != null &&
        previous != null &&
        Widget.canUpdate(swipeParent.child, previous)) {
      swipeParent.child = previous;
    }

    if (Widget.canUpdate(_current.child, widget.child)) {
      _current.child = widget.child;
      return;
    }

    _removeWhenHidden(
      _current,
      _current.leave(
        widget.isForward
            ? MotionSlide.leftHalf.offset
            : MotionSlide.rightHalf.offset,
      ),
    );
    _current = _createEntry(
      widget.child,
      enterFrom: widget.isForward
          ? MotionSlide.rightHalf.offset
          : MotionSlide.leftHalf.offset,
    )..controller.forward();
  }

  @override
  void dispose() {
    _current.controller.dispose();
    _swipeParent?.controller.dispose();
    for (final entry in _leaving) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final swipeParent = _swipeParent;

    // The gesture detector stays in the tree even when swiping is off,
    // so the levels are not mounted again when it turns on or off.
    return RawGestureDetector(
      gestures: {
        if (_canSwipe)
          HorizontalDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                HorizontalDragGestureRecognizer
              >(
                HorizontalDragGestureRecognizer.new,
                (recognizer) => recognizer
                  ..onStart = _onSwipeStart
                  ..onUpdate = _onSwipeUpdate
                  ..onEnd = _onSwipeEnd
                  ..onCancel = _onSwipeCancel,
              ),
      },
      child: IgnorePointer(
        ignoring: _isTracking || _isSettling,
        child: Stack(
          alignment: widget.isForward
              ? Alignment.centerRight
              : Alignment.centerLeft,
          children: [
            for (final entry in _leaving) _buildEntry(entry),
            if (swipeParent != null) _buildEntry(swipeParent),
            _buildEntry(_current),
          ],
        ),
      ),
    );
  }

  Widget _buildEntry(SmartContextMenuLevelEntry entry) {
    return FadeSlideTransition(
      key: ObjectKey(entry),
      opacity: entry.fade,
      position: entry.position,
      child: entry.child,
    );
  }

  SmartContextMenuLevelEntry _createEntry(
    Widget child, {
    required Offset enterFrom,
  }) {
    return SmartContextMenuLevelEntry(
      child: child,
      controller: AnimationController(
        vsync: this,
        duration: MotionDurations.standard,
      ),
      enterFrom: enterFrom,
    );
  }

  /// Keeps [entry] on the screen until [hidden] completes.
  void _removeWhenHidden(
    SmartContextMenuLevelEntry entry,
    TickerFuture hidden,
  ) {
    _leaving.add(entry);
    hidden.whenCompleteOrCancel(() {
      if (!mounted || entry.controller.value != 0) return;
      setState(() => _leaving.remove(entry));
      entry.controller.dispose();
    });
  }

  void _onSwipeStart(DragStartDetails details) {
    final previous = widget.previous;
    final width = context.size?.width ?? 0;
    final isIdle =
        _swipeParent == null &&
        _leaving.isEmpty &&
        !_current.controller.isAnimating;
    if (previous == null || width == 0 || !isIdle) return;

    final parent = _createEntry(
      previous,
      enterFrom: MotionSlide.leftHalf.offset,
    )..track(hiddenOffset: MotionSlide.leftHalf.offset, fades: true);
    _current.track(hiddenOffset: MotionSlide.right.offset, fades: false);

    setState(() {
      _swipeParent = parent;
      _swipeWidth = width;
      _swipeProgress = 0;
      _isTracking = true;
    });
    widget.isSwiping?.value = true;
  }

  void _onSwipeUpdate(DragUpdateDetails details) {
    final parent = _swipeParent;
    if (!_isTracking || parent == null) return;

    final delta = (details.primaryDelta ?? 0) / _swipeWidth;
    _swipeProgress = (_swipeProgress + delta).clamp(0.0, 1.0);
    _current.controller.value = 1 - _swipeProgress;
    parent.controller.value = _swipeProgress;
  }

  void _onSwipeEnd(DragEndDetails details) {
    if (!_isTracking) return;

    final velocity = (details.primaryVelocity ?? 0) / _swipeWidth;
    const threshold = GestureThresholds.swipeBackVelocity;
    final goBack =
        velocity >= threshold ||
        (velocity > -threshold &&
            _swipeProgress > GestureThresholds.swipeBackDistance);
    _finishSwipe(goBack: goBack);
  }

  void _onSwipeCancel() {
    if (_isTracking) _finishSwipe(goBack: false);
  }

  void _finishSwipe({required bool goBack}) {
    final parent = _swipeParent!;
    final remaining = goBack ? 1 - _swipeProgress : _swipeProgress;
    final duration = MotionDurations.standard * remaining;

    setState(() {
      _isTracking = false;
      _isSettling = true;
    });
    widget.isSwiping?.value = false;

    if (goBack) {
      _removeWhenHidden(
        _current,
        _current.settle(show: false, duration: duration),
      );
      _current = parent;
      _swipeParent = null;
      parent.settle(show: true, duration: duration).whenCompleteOrCancel(() {
        if (mounted) setState(() => _isSettling = false);
      });
      widget.onSwipeBack();
      return;
    }

    _current.settle(show: true, duration: duration);
    parent.settle(show: false, duration: duration).whenCompleteOrCancel(() {
      if (!mounted) return;
      setState(() {
        _swipeParent = null;
        _isSettling = false;
      });
      parent.controller.dispose();
    });
  }
}
