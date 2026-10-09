import 'dart:async' show Timer;

import 'package:flutter/animation.dart';

import '../../core/ui/motion/tokens/motion_durations.dart';

/// The animation of the header slivers.
///
/// The slivers start to appear [delay] after the menu starts opening; with
/// no delay, they follow the opening. If the content scrolls as the menu
/// opens, they also wait until the preview is in place: the preview flies
/// above the route, so it would cover a pinned sliver over it. For the same
/// reason, they hide at once if the content is scrolled when the menu
/// closes; otherwise they hide with the menu.
final class SmartContextMenuHeaderAnimation {
  final Animation<double> route;
  final Duration delay;

  /// Whether the content of the menu is scrolled.
  final bool Function() isScrolled;

  final AnimationController _appearance;
  Timer? _delayTimer;
  bool _isDelayOver;
  bool _waitsForPreview = false;

  /// Runs from 0 to 1 as the slivers appear and back as they hide.
  late final Animation<double> animation = AnimationMin(_appearance, route);

  SmartContextMenuHeaderAnimation({
    required this.route,
    required this.delay,
    required this.isScrolled,
    required TickerProvider vsync,
  }) : _appearance = AnimationController(
         vsync: vsync,
         duration: MotionDurations.standard,
       ),
       _isDelayOver = delay <= Duration.zero {
    if (_isDelayOver) {
      _appearance.value = 1;
    } else {
      _delayTimer = Timer(delay, _onDelayOver);
    }
    route.addStatusListener(_onRouteStatus);
  }

  /// Keeps the slivers hidden until the preview is in place.
  ///
  /// Call it when the content scrolls as the menu opens. Does nothing once
  /// the menu is open.
  void waitForPreview() {
    if (route.status != AnimationStatus.forward || _waitsForPreview) return;
    _waitsForPreview = true;
    _appearance.value = 0;
  }

  void dispose() {
    _delayTimer?.cancel();
    route.removeStatusListener(_onRouteStatus);
    _appearance.dispose();
  }

  void _onDelayOver() {
    _isDelayOver = true;
    _appear();
  }

  void _onRouteStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        _appear();
      case AnimationStatus.reverse:
        _delayTimer?.cancel();
        if (isScrolled()) _appearance.value = 0;
      case AnimationStatus.forward || AnimationStatus.dismissed:
        break;
    }
  }

  void _appear() {
    final bool isOpening = route.status == AnimationStatus.forward;
    final bool isOpen = route.status == AnimationStatus.completed;
    if (!_isDelayOver || !(isOpening || isOpen)) return;
    if (_waitsForPreview && !isOpen) return;
    _appearance.forward();
  }
}
