import 'package:flutter/widgets.dart' show Color;
import 'package:meta/meta.dart' show internal;

final class SmartContextMenuItemState {
  final bool isPressed;
  final bool isDisabled;
  final bool isDestructive;
  final Color textColor;
  final bool isLoading;
  final bool hasError;

  @internal
  const SmartContextMenuItemState({
    required this.isPressed,
    required this.isDisabled,
    required this.isDestructive,
    required this.textColor,
    required this.isLoading,
    required this.hasError,
  });
}
