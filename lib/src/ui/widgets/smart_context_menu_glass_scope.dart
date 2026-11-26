import 'dart:ui' show FragmentProgram;

import 'package:flutter/widgets.dart';

/// Supplies the Lab's glass shader to the anchor before it pushes its route.
final class SmartContextMenuGlassScope extends InheritedWidget {
  static const shaderAsset =
      'packages/smart_context_menu/lib/src/ui/shaders/smart_context_menu_glass.frag';

  final FragmentProgram program;

  const SmartContextMenuGlassScope({
    super.key,
    required this.program,
    required super.child,
  });

  static SmartContextMenuGlassScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SmartContextMenuGlassScope>();

  @override
  bool updateShouldNotify(SmartContextMenuGlassScope oldWidget) =>
      program != oldWidget.program;
}
