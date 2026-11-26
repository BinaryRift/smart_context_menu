import 'dart:ui' show FragmentProgram;

import 'package:flutter/widgets.dart';

/// Opts the anchor into the internal Lab prototype before it pushes its route.
final class SmartContextMenuGlassPrototype extends InheritedWidget {
  static const shaderAsset =
      'packages/smart_context_menu/lib/src/ui/shaders/smart_context_menu_glass.frag';

  final FragmentProgram program;
  final bool fadeWholeMenu;

  const SmartContextMenuGlassPrototype({
    super.key,
    required this.program,
    required this.fadeWholeMenu,
    required super.child,
  });

  static SmartContextMenuGlassPrototype? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SmartContextMenuGlassPrototype>();

  @override
  bool updateShouldNotify(SmartContextMenuGlassPrototype oldWidget) =>
      program != oldWidget.program || fadeWholeMenu != oldWidget.fadeWholeMenu;
}
