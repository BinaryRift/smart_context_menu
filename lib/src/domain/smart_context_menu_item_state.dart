import 'package:flutter/widgets.dart' show Color;

final class SmartContextMenuItemState {
  final bool isPressed;
  final bool isDisabled;
  final bool isDestructive;
  final Color textColor;
  final bool isLoading;
  final bool hasError;
  
  SmartContextMenuItemState({
    required this.isPressed,
    required this.isDisabled,
    required this.isDestructive,
    required this.textColor,
    required this.isLoading,
    required this.hasError,
  });
}