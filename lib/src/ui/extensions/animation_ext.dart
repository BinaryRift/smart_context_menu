import 'dart:async' show Completer;

import 'package:flutter/animation.dart';

extension SmartContextMenuClosingAnimation on Animation<double> {
  /// Completes when this animation, running back to 0 as a route closes,
  /// has covered [fraction] of the way, or has stopped.
  ///
  /// Follows the animation rather than the clock, so it keeps in step when
  /// animations run slower, for example with `timeDilation`.
  Future<void> closedBy(double fraction) {
    final completer = Completer<void>();

    bool isDone() => value <= 1 - fraction || status != AnimationStatus.reverse;

    late final void Function() onChange;
    void onStatus(AnimationStatus _) => onChange();
    onChange = () {
      if (completer.isCompleted || !isDone()) return;
      removeListener(onChange);
      removeStatusListener(onStatus);
      completer.complete();
    };

    if (isDone()) return Future.value();
    addListener(onChange);
    addStatusListener(onStatus);
    return completer.future;
  }
}
