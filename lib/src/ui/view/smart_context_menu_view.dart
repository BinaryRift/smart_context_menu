import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/material.dart';

import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_traslation.dart';
import '../../controllers/smart_context_menu_overlay_controller.dart';
import '../../domain/smart_context_menu_navigator.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../state/smart_context_menu_stretch_controller.dart';
import '../widgets/smart_context_menu_blur_box.dart';
import '../widgets/smart_context_menu_level_switcher.dart';
import '../widgets/smart_context_menu_pointer_tracker.dart';
import 'smart_context_menu_level_view.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../widgets/smart_context_menu_shadow_box.dart';
import '../widgets/widget_size_listener.dart';

final class SmartContextMenuView extends StatefulWidget {
  final List<SmartContextMenuItem> initialItems;
  final SmartContextMenuConfig config;
  final ValueNotifier<double> heightNotifier;
  final ValueNotifier<Offset> previewMotionNotifier;

  const SmartContextMenuView({
    super.key,
    required this.initialItems,
    required this.config,
    required this.heightNotifier,
    required this.previewMotionNotifier,
  });

  @override
  State<SmartContextMenuView> createState() => _SmartContextMenuViewState();
}

final class _SmartContextMenuViewState extends State<SmartContextMenuView>
    implements SmartContextMenuNavigator {
  late final SmartContextMenuOverlayController _controller;
  late final SmartContextMenuHoverController _hoverController;
  late final SmartContextMenuStretchController _stretchController;

  SmartContextMenuConfig get _config => widget.config;

  BoxDecoration get _defaultDecoration => BoxDecoration(
    color: CupertinoDynamicColor.resolve(_config.style.menuColor, context),
    borderRadius: _config.style.borderRadius,
    border: Border.all(
      color: CupertinoDynamicColor.resolve(_config.style.borderColor, context),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = SmartContextMenuOverlayController(
      navigator: this,
      initialItems: widget.initialItems,
      enableHaptics: _config.enableHaptics,
    )..addListener(_onControllerUpdate);
    _hoverController = SmartContextMenuHoverController();
    _stretchController = SmartContextMenuStretchController();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _hoverController.dispose();
    _stretchController.dispose();
    super.dispose();
  }

  @override
  Future<void> dismissWithDelay() async {
    final route = ModalRoute.of(context);
    if (!mounted || route == null) return;

    if (Navigator.of(context).canPop()) {
      final delay = route.transitionDuration * 0.5;
      Navigator.of(context).pop();
      await Future.delayed(delay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return WidgetSizeListener(
      onSizeChanged: _onSizeChanged,
      child: SmartContextMenuShadowBox(
        borderRadius: _config.style.borderRadius,
        child: SmartContextMenuBlurBox(
          blur: _config.style.menuBlur,
          borderRadius: _config.style.borderRadius,
          child: ListenableBuilder(
            listenable: _stretchController,
            builder: (context, child) => AnimatedContainer(
              duration: MotionDurations.fast,
              curve: MotionCurves.quartOut,
              transformAlignment: Alignment.center,
              transform: _stretchController.transform,
              width: _config.menuWidth,
              decoration: _config.style.menuDecoration ?? _defaultDecoration,
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
            child: AnimatedSize(
              duration: MotionDurations.standard,
              curve: MotionCurves.quartOut,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * _config.menuHeightFactor,
                ),
                child: SmartContextMenuPointerTracker(
                  hoverController: _hoverController,
                  onDrag: _setMenuEffect,
                  onRelease: _resetMenuEffect,
                  child: SmartContextMenuLevelSwitcher(
                    isForward: _controller.isForward,
                    child: SmartContextMenuLevelView(
                      key: ValueKey(_controller.stackLength),
                      level: _controller.currentLevel,
                      controller: _controller,
                      config: _config,
                      hoverController: _hoverController,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onControllerUpdate() => setState(() {});

  void _onSizeChanged(Size size) {
    final newHeight = size.height.roundToDouble();
    final oldHeight = widget.heightNotifier.value.roundToDouble();

    if (oldHeight != newHeight) {
      widget.heightNotifier.value = newHeight;
    }
  }

  void _setMenuEffect(Offset delta) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;

    final RenderBox? box = renderObject as RenderBox?;
    if (box == null || !box.hasSize) return;

    _stretchController.stretch(delta, box.size);
    widget.previewMotionNotifier.value = _stretchController.translation;
  }

  void _resetMenuEffect() {
    _stretchController.reset();
    widget.previewMotionNotifier.value = MotionTranslation.none.toOffset;
  }
}
