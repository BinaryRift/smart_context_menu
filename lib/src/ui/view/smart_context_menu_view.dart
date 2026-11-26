// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/widgets.dart';

import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_timing.dart';
import '../../core/ui/motion/tokens/motion_translation.dart';
import '../../controllers/smart_context_menu_overlay_controller.dart';
import '../../domain/smart_context_menu_level.dart';
import '../../domain/smart_context_menu_navigator.dart';
import '../extensions/animation_ext.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../state/smart_context_menu_stretch_controller.dart';
import '../widgets/smart_context_menu_blur_box.dart';
import '../widgets/smart_context_menu_glass_prototype.dart';
import '../widgets/smart_context_menu_glass_surface.dart';
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
  final SmartContextMenuGlassPrototype? glass;
  final Animation<double> glassOpacity;

  const SmartContextMenuView({
    super.key,
    required this.initialItems,
    required this.config,
    required this.heightNotifier,
    required this.previewMotionNotifier,
    this.glass,
    required this.glassOpacity,
  });

  @override
  State<SmartContextMenuView> createState() => _SmartContextMenuViewState();
}

final class _SmartContextMenuViewState extends State<SmartContextMenuView>
    implements SmartContextMenuNavigator {
  late final SmartContextMenuOverlayController _controller;
  late final SmartContextMenuHoverController _hoverController;
  late final SmartContextMenuStretchController _stretchController;
  final ValueNotifier<bool> _isSwiping = ValueNotifier(false);

  SmartContextMenuConfig get _config => widget.config;

  BoxDecoration get _defaultDecoration => BoxDecoration(
    color: CupertinoDynamicColor.resolve(_config.style.menuColor, context),
    borderRadius: _config.style.borderRadius,
  );

  // The border is painted over the levels, so the back item does not
  // cover it while a level slides.
  BoxDecoration get _defaultBorder => BoxDecoration(
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
    _isSwiping.dispose();
    super.dispose();
  }

  @override
  Future<void> dismissWithDelay() async {
    final route = ModalRoute.of(context);
    if (!mounted || route == null) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      await route.animation?.closedBy(MotionTiming.closingAction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final levels = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * _config.menuHeightFactor,
      ),
      child: SmartContextMenuPointerTracker(
        hoverController: _hoverController,
        isSwiping: _isSwiping,
        onDrag: _setMenuEffect,
        onRelease: _resetMenuEffect,
        child: SmartContextMenuLevelSwitcher(
          isForward: _controller.isForward,
          enableSwipeBack: _config.enableSwipeBack,
          isSwiping: _isSwiping,
          onSwipeBack: _controller.popSubmenu,
          previous: _buildPreviousLevel(),
          child: _buildLevel(
            _controller.currentLevel,
            depth: _controller.stackLength,
          ),
        ),
      ),
    );
    final glass = widget.glass;

    // The stretch moves the surface and its shadow together with the menu.
    return WidgetSizeListener(
      onSizeChanged: _onSizeChanged,
      child: ListenableBuilder(
        listenable: _stretchController,
        builder: (context, child) => AnimatedContainer(
          duration: MotionDurations.fast,
          curve: MotionCurves.quartOut,
          transformAlignment: Alignment.center,
          transform: _stretchController.transform,
          child: child,
        ),
        child: glass == null
            ? _buildStandardSurface(levels)
            : _buildGlassSurface(context, glass, levels),
      ),
    );
  }

  Widget _buildStandardSurface(Widget levels) {
    return SmartContextMenuShadowBox(
      borderRadius: _config.style.borderRadius,
      shadows: _config.style.menuShadows,
      child: SmartContextMenuBlurBox(
        blur: _config.style.menuBlur,
        borderRadius: _config.style.borderRadius,
        child: Container(
          width: _config.menuWidth,
          decoration: _config.style.menuDecoration ?? _defaultDecoration,
          foregroundDecoration: _config.style.menuDecoration == null
              ? _defaultBorder
              : null,
          clipBehavior: Clip.antiAlias,
          child: levels,
        ),
      ),
    );
  }

  Widget _buildGlassSurface(
    BuildContext context,
    SmartContextMenuGlassPrototype glass,
    Widget levels,
  ) {
    final opacity = glass.fadeWholeMenu
        ? kAlwaysCompleteAnimation
        : widget.glassOpacity;

    return SizedBox(
      width: _config.menuWidth,
      child: SmartContextMenuGlassSurface(
        program: glass.program,
        opacity: opacity,
        borderRadius: _config.style.borderRadius,
        shadows: _config.style.menuShadows,
        tint: CupertinoDynamicColor.resolve(_glassTint, context),
        child: levels,
      ),
    );
  }

  static const _glassTint = CupertinoDynamicColor.withBrightness(
    color: Color(0x92F7FAFF),
    darkColor: Color(0x9C161B24),
  );

  Widget? _buildPreviousLevel() {
    final level = _controller.previousLevel;
    if (level == null) return null;
    return _buildLevel(level, depth: _controller.stackLength - 1);
  }

  // The key is the depth, so a level keeps its key when it becomes current
  // after a swipe back.
  Widget _buildLevel(SmartMenuLevel level, {required int depth}) {
    return SmartContextMenuLevelView(
      key: ValueKey(depth),
      level: level,
      controller: _controller,
      config: _config,
      hoverController: _hoverController,
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
