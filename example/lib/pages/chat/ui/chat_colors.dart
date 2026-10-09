import 'package:flutter/cupertino.dart';

abstract final class ChatColors {
  /// Close to black in the dark theme, but not the black of the bars.
  static const background = CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: Color(0xFF121214),
  );

  /// The bubbles of other members and the reactions under messages.
  static const bubble = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE5E5EA),
    darkColor: Color(0xFF2C2C2E),
  );

  static const myBubble = CupertinoColors.activeBlue;
}
