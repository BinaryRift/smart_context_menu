import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_opacity.dart';
import '../../core/ui/motion/tokens/motion_slides.dart';

/// A menu level on the screen with the animation of its appearance.
///
/// [controller] is 1 while the level is in place and 0 while it is hidden.
/// The level moves between two points: [offset] goes from the start point
/// to the end point as [controller] goes from the start value to the end
/// value. Each motion starts from where the level is, so an interrupted
/// level does not jump. [presence] moves along with [offset].
final class SmartContextMenuLevelEntry {
  Widget child;
  final AnimationController controller;

  double _fromValue = 0;
  double _fromPresence = 0;
  Offset _fromOffset;
  double _toValue = 1;
  Offset _toOffset = MotionSlide.none.offset;
  Curve _curve = MotionCurves.emphasized;
  Curve? _fade = MotionCurves.levelFadeIn;

  /// Where a tracked level hides, see [track].
  Offset _hiddenOffset;

  /// [offset], updated with [controller].
  late final Animation<Offset> position = _EntryValue(controller, () => offset);

  /// [opacity], updated with [controller].
  late final Animation<double> fade = _EntryValue(controller, () => opacity);

  /// Creates a level that comes in from [enterFrom] as [controller] goes
  /// from 0 to 1.
  SmartContextMenuLevelEntry({
    required this.child,
    required this.controller,
    required Offset enterFrom,
  }) : _fromOffset = enterFrom,
       _hiddenOffset = enterFrom;

  /// The current shift of the level, as a fraction of its size.
  Offset get offset => Offset.lerp(_fromOffset, _toOffset, _progress)!;

  /// How much the level is on the screen: 1 in place, 0 hidden.
  ///
  /// Used as the weight of the level height in the menu height.
  double get presence => lerpDouble(_fromPresence, _toValue, _progress)!;

  /// The curved progress of the current motion.
  double get _progress {
    final span = _toValue - _fromValue;
    final progress = span == 0
        ? 1.0
        : ((controller.value - _fromValue) / span).clamp(0.0, 1.0);
    return _curve.transform(progress);
  }

  /// The current opacity of the level.
  double get opacity =>
      _fade?.transform(controller.value) ?? MotionOpacity.visible.value;

  /// Leaves towards [to], fading out.
  TickerFuture leave(Offset to) {
    _moveTo(value: 0, offset: to, curve: MotionCurves.emphasized);
    _fade = MotionCurves.levelFadeOut;
    return controller.reverse();
  }

  /// Hands [controller] to a gesture: the level is hidden at [hiddenOffset]
  /// at 0, in place at 1 and follows [controller] linearly in between.
  ///
  /// If [fades] is false, the level stays opaque.
  void track({required Offset hiddenOffset, required bool fades}) {
    _hiddenOffset = hiddenOffset;
    _fromValue = 0;
    _fromPresence = 0;
    _fromOffset = hiddenOffset;
    _toValue = 1;
    _toOffset = MotionSlide.none.offset;
    _curve = Curves.linear;
    _fade = fades ? MotionCurves.levelFadeIn : null;
  }

  /// Ends [track]: moves the level in place if [show] is true or to
  /// the hidden offset otherwise, for [duration].
  TickerFuture settle({required bool show, required Duration duration}) {
    _moveTo(
      value: show ? 1 : 0,
      offset: show ? MotionSlide.none.offset : _hiddenOffset,
      curve: MotionCurves.emphasized,
    );
    return controller.animateTo(show ? 1 : 0, duration: duration);
  }

  void _moveTo({
    required double value,
    required Offset offset,
    required Curve curve,
  }) {
    _fromOffset = this.offset;
    _fromPresence = presence;
    _fromValue = controller.value;
    _toValue = value;
    _toOffset = offset;
    _curve = curve;
  }
}

/// A value of [SmartContextMenuLevelEntry], updated with its controller.
final class _EntryValue<T> extends Animation<T>
    with AnimationWithParentMixin<double> {
  @override
  final Animation<double> parent;
  final T Function() _read;

  _EntryValue(this.parent, this._read);

  @override
  T get value => _read();
}
