import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../core/ui/gestures/gesture_thresholds.dart';
import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_slides.dart';
import '../../core/ui/motion/transitions/fade_slide_transition.dart';
import '../state/smart_context_menu_level_entry.dart';
import 'smart_context_menu_level_stack.dart';

/// Switches menu levels: a submenu slides in from the right over the
/// current level, which moves to the left; going back, the submenu slides
/// away to the right and the parent comes out from under it. The submenu
/// stays opaque and the level under it shows only to its left, as in
/// a swipe back.
///
/// With [enableSwipeBack] and a [previous] level, swiping right drags
/// the current level away and reveals [previous]. If the swipe goes far
/// or fast enough, [onSwipeBack] is called once released.
///
/// The height follows the transitions: it moves from the height of one
/// level to the other along with the levels. A change of height inside
/// a level, such as items loaded in place of the loader, is animated
/// by the level itself.
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

  /// While the levels move, [_revealed] is visible only to the left of
  /// [_cover], as if [_cover] were opaque.
  SmartContextMenuLevelEntry? _revealed;
  SmartContextMenuLevelEntry? _cover;
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

    final isForward = widget.isForward;
    final leaving = _current;
    final hidden = leaving.leave(
      isForward ? MotionSlide.leftHalf.offset : MotionSlide.right.offset,
      fades: isForward,
    );
    _removeWhenHidden(leaving, hidden);
    final entering = _createEntry(
      widget.child,
      enterFrom: isForward
          ? MotionSlide.right.offset
          : MotionSlide.leftHalf.offset,
      fades: !isForward,
    );
    final shown = entering.controller.forward();
    _current = entering;

    final cover = isForward ? entering : leaving;
    _revealed = isForward ? leaving : entering;
    _cover = cover;
    (isForward ? shown : hidden).whenCompleteOrCancel(() {
      if (!mounted || _cover != cover) return;
      setState(() {
        _revealed = null;
        _cover = null;
      });
    });
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
    final entries = [..._leaving, ?swipeParent, _current];
    final levels = [for (final entry in entries) _buildEntry(entry)];

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
        child: AnimatedBuilder(
          animation: Listenable.merge([
            for (final entry in entries) entry.controller,
          ]),
          builder: (context, _) => SmartContextMenuLevelStack(
            presences: [for (final entry in entries) entry.presence],
            children: levels,
          ),
        ),
      ),
    );
  }

  Widget _buildEntry(SmartContextMenuLevelEntry entry) {
    final cover = entry == _revealed ? _cover : null;

    // The clip stays in the tree with Clip.none, so the level is not
    // mounted again when a swipe starts or ends.
    return ClipRect(
      key: ObjectKey(entry),
      clipBehavior: cover == null ? Clip.none : Clip.hardEdge,
      clipper: cover == null ? null : _UncoveredClipper(cover.position),
      child: _buildTransition(entry),
    );
  }

  Widget _buildTransition(SmartContextMenuLevelEntry entry) {
    return FadeSlideTransition(
      opacity: entry.fade,
      position: entry.position,
      child: AnimatedSize(
        duration: MotionDurations.standard,
        curve: MotionCurves.quartOut,
        alignment: Alignment.topCenter,
        child: entry.child,
      ),
    );
  }

  SmartContextMenuLevelEntry _createEntry(
    Widget child, {
    required Offset enterFrom,
    bool fades = true,
  }) {
    return SmartContextMenuLevelEntry(
      child: child,
      controller: AnimationController(
        vsync: this,
        duration: MotionDurations.standard,
      ),
      enterFrom: enterFrom,
      fades: fades,
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
      _revealed = parent;
      _cover = _current;
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
        if (mounted) setState(_endSettling);
      });
      widget.onSwipeBack();
      return;
    }

    _current.settle(show: true, duration: duration);
    parent.settle(show: false, duration: duration).whenCompleteOrCancel(() {
      if (!mounted) return;
      setState(() {
        _swipeParent = null;
        _endSettling();
      });
      parent.controller.dispose();
    });
  }

  void _endSettling() {
    _isSettling = false;
    _revealed = null;
    _cover = null;
  }
}

/// Clips to the part of the level stack left of a covering level that
/// slides right by [cover], a fraction of its width.
final class _UncoveredClipper extends CustomClipper<Rect> {
  final Animation<Offset> cover;

  _UncoveredClipper(this.cover) : super(reclip: cover);

  @override
  Rect getClip(Size size) {
    final visible = cover.value.dx.clamp(0.0, 1.0);
    return Rect.fromLTWH(0, 0, size.width * visible, size.height);
  }

  @override
  bool shouldReclip(_UncoveredClipper oldClipper) => oldClipper.cover != cover;
}
