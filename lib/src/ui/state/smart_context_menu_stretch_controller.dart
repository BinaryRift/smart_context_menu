import 'package:flutter/widgets.dart'
    show ChangeNotifier, Matrix4, Offset, Size;

import '../../core/ui/motion/tokens/motion_scales.dart';
import '../../core/ui/motion/tokens/motion_translation_factor.dart';
import '../../core/ui/motion/tokens/motion_traslation.dart';

/// Stretches the menu towards the pointer while it is dragged.
final class SmartContextMenuStretchController extends ChangeNotifier {
  double _scaleX = MotionScale.none.x;
  double _scaleY = MotionScale.none.y;
  double _translateX = MotionTranslationFactor.none.dx;
  double _translateY = MotionTranslationFactor.none.dy;

  /// The menu shift, followed by the preview.
  Offset get translation => Offset(_translateX, _translateY);

  Matrix4 get transform => Matrix4.identity()
    ..setTranslationRaw(
      _translateX,
      _translateY,
      MotionTranslationFactor.none.dz,
    )
    ..setEntry(0, 0, _scaleX)
    ..setEntry(1, 1, _scaleY)
    ..setEntry(2, 2, MotionScale.none.value);

  bool get _isStretched =>
      _scaleX != MotionScale.none.x ||
      _scaleY != MotionScale.none.y ||
      _translateX != MotionTranslationFactor.none.dx ||
      _translateY != MotionTranslationFactor.none.dy;

  /// Stretches the menu of [menuSize] by the pointer offset [delta]
  /// from the pointer-down position.
  void stretch(Offset delta, Size menuSize) {
    final maxTranslation = MotionTranslationFactor.full;
    final double relX = (delta.dx / menuSize.width).clamp(
      -maxTranslation.dx,
      maxTranslation.dx,
    );
    final double relY = (delta.dy / menuSize.height).clamp(
      -maxTranslation.dy,
      maxTranslation.dy,
    );

    final maxScale = MotionScale.stretch;
    _scaleX =
        MotionScale.none.x + relX.abs() * (maxScale.x - MotionScale.none.x);
    _scaleY =
        MotionScale.none.y + relY.abs() * (maxScale.y - MotionScale.none.y);

    _translateX = relX * MotionTranslation.subtle.dx;
    _translateY = relY * MotionTranslation.subtle.dy;

    notifyListeners();
  }

  void reset() {
    if (!_isStretched) return;
    _scaleX = MotionScale.none.x;
    _scaleY = MotionScale.none.y;
    _translateX = MotionTranslationFactor.none.dx;
    _translateY = MotionTranslationFactor.none.dy;
    notifyListeners();
  }
}
