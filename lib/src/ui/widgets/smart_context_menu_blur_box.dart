import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../domain/smart_context_menu_config.dart';

final class SmartContextMenuBlurBox extends StatelessWidget {
  final SmartContextMenuConfig config;
  final Widget child;

  const SmartContextMenuBlurBox({
    super.key,
    required this.config,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (config.menuBlur != null) {
      return ClipRRect(
        borderRadius: config.borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: config.menuBlur!.sigmaX,
            sigmaY: config.menuBlur!.sigmaY,
          ),
          child: child,
        ),
      );
    }
    return child;
  }
}
