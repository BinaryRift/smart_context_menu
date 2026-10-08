import 'dart:async' show FutureOr;
import 'dart:ui' as ui show Image;
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart'
    show PageRoute, Rect, Widget, Color, BuildContext, Animation;

import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_header_details.dart';
import '../../domain/smart_context_menu_item.dart';
import '../view/smart_context_menu_overlay.dart';

final class SmartContextMenuRoute extends PageRoute<void> {
  final Rect anchorRect;
  final ui.Image? snapshot;
  final String heroTag;
  final List<SmartContextMenuItem> items;
  final SmartContextMenuConfig config;
  final FutureOr<void> Function()? onPreviewTap;
  final SmartContextMenuHeaderBuilder? headerSliversBuilder;

  @override
  final String? barrierLabel;

  SmartContextMenuRoute({
    required this.anchorRect,
    required this.snapshot,
    required this.heroTag,
    required this.items,
    required this.config,
    this.onPreviewTap,
    this.headerSliversBuilder,
    this.barrierLabel,
  });

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => config.barrierDismissible;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  Duration get transitionDuration => MotionDurations.standard;

  @override
  Duration get reverseTransitionDuration => MotionDurations.fast;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return SmartContextMenuOverlay(
      routeAnimation: animation,
      anchorRect: anchorRect,
      heroTag: heroTag,
      items: items,
      config: config,
      snapshot: snapshot,
      onPreviewTap: onPreviewTap,
      headerSliversBuilder: headerSliversBuilder,
    );
  }
}
