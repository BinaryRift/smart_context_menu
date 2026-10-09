import 'package:flutter/cupertino.dart';

/// [color] with its darker high contrast variant in the light theme,
/// so a tinted item reads well on the light menu.
CupertinoDynamicColor readableTint(CupertinoDynamicColor color) {
  return CupertinoDynamicColor.withBrightness(
    color: color.highContrastColor,
    darkColor: color.darkColor,
  );
}
