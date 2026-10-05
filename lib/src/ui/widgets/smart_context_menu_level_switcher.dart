import 'package:flutter/widgets.dart';

import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_slides.dart';

/// Switches menu levels: a submenu slides in from the right,
/// the parent level from the left.
///
/// Give each level its own key, so a new level is animated in.
final class SmartContextMenuLevelSwitcher extends StatefulWidget {
  /// Whether [child] is a submenu opened from the current level.
  final bool isForward;
  final Widget child;

  const SmartContextMenuLevelSwitcher({
    super.key,
    required this.isForward,
    required this.child,
  });

  @override
  State<SmartContextMenuLevelSwitcher> createState() =>
      _SmartContextMenuLevelSwitcherState();
}

final class _SmartContextMenuLevelSwitcherState
    extends State<SmartContextMenuLevelSwitcher> {
  // The builders are state methods, so they stay equal between builds.
  // AnimatedSwitcher rebuilds the transitions of all levels when its
  // transitionBuilder changes, and a leaving level must keep the direction
  // it came in with.
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: MotionDurations.standard,
      layoutBuilder: _layoutBuilder,
      transitionBuilder: _transitionBuilder,
      child: widget.child,
    );
  }

  Widget _layoutBuilder(Widget? currentChild, List<Widget> previousChildren) {
    return Stack(
      alignment: widget.isForward
          ? Alignment.centerRight
          : Alignment.centerLeft,
      children: [...previousChildren, ?currentChild],
    );
  }

  Widget _transitionBuilder(Widget child, Animation<double> animation) {
    return _LevelTransition(
      animation: animation,
      slideBegin: widget.isForward
          ? MotionSlide.rightHalf.offset
          : MotionSlide.leftHalf.offset,
      child: child,
    );
  }
}

/// Fades and slides a level in from [slideBegin].
final class _LevelTransition extends StatefulWidget {
  final Animation<double> animation;
  final Offset slideBegin;
  final Widget child;

  const _LevelTransition({
    required this.animation,
    required this.slideBegin,
    required this.child,
  });

  @override
  State<_LevelTransition> createState() => _LevelTransitionState();
}

final class _LevelTransitionState extends State<_LevelTransition> {
  late CurvedAnimation _fade;
  late CurvedAnimation _slide;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _createAnimations();
  }

  @override
  void didUpdateWidget(_LevelTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation ||
        widget.slideBegin != oldWidget.slideBegin) {
      _disposeAnimations();
      _createAnimations();
    }
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  void _createAnimations() {
    _fade = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    _slide = CurvedAnimation(
      parent: widget.animation,
      curve: MotionCurves.emphasized,
    );
    _position = Tween<Offset>(
      begin: widget.slideBegin,
      end: MotionSlide.none.offset,
    ).animate(_slide);
  }

  void _disposeAnimations() {
    _fade.dispose();
    _slide.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _position, child: widget.child),
      ),
    );
  }
}
