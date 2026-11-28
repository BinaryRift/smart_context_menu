import 'dart:async' show unawaited;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart'
    show CupertinoDynamicColor, CupertinoTheme;
import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_style.dart';
import '../../domain/smart_context_menu_surface.dart';
import '../state/smart_context_menu_glass_shader.dart';
import '../theme/smart_context_menu_theme.dart';
import 'smart_context_menu_blur_box.dart';
import 'smart_context_menu_glass_surface.dart';
import 'smart_context_menu_highlight.dart';
import 'smart_context_menu_shadow_box.dart';

/// The same Liquid Glass and Standard surfaces used by [SmartContextMenu],
/// sized to fit any child widget.
///
/// A standalone panel starts on Standard while Glass loads and updates when
/// the shader is ready. It uses Standard when shader filters are unavailable,
/// loading fails, or the surrounding [MediaQueryData.highContrast] is enabled.
/// With no explicit [style], a panel inside an open menu uses the surface
/// selected for that opening.
final class SmartContextMenuPanel extends StatefulWidget {
  /// The surface, radius and shadows to use. When omitted, the panel uses
  /// the active menu's style or the nearest [SmartContextMenuTheme].
  final SmartContextMenuStyle? style;

  /// Overrides the radius from [style]. A custom Standard decoration still
  /// supplies its own shape and clipping.
  final BorderRadiusGeometry? borderRadius;

  /// The panel width. When omitted, the width follows the child and constraints.
  final double? width;

  /// An opacity animation for the panel, its contents and its backdrop effects.
  final Animation<double> opacity;

  /// The widget displayed on the panel.
  final Widget child;

  const SmartContextMenuPanel({
    super.key,
    this.style,
    this.borderRadius,
    this.width,
    this.opacity = const AlwaysStoppedAnimation(1),
    required this.child,
  });

  @override
  State<SmartContextMenuPanel> createState() => _SmartContextMenuPanelState();
}

final class _SmartContextMenuPanelState extends State<SmartContextMenuPanel> {
  static final _shader = SmartContextMenuGlassShader.shared;

  final _childKey = GlobalKey();
  SmartContextMenuPanelScope? _menu;
  late SmartContextMenuStyle _style;
  bool _loadGlass = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveStyle();
  }

  @override
  void didUpdateWidget(SmartContextMenuPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.style != oldWidget.style) _resolveStyle();
  }

  void _resolveStyle() {
    _menu = widget.style == null
        ? SmartContextMenuPanelScope.maybeOf(context)
        : null;
    _style =
        widget.style ?? _menu?.style ?? SmartContextMenuTheme.of(context).style;
    final loadGlass =
        _menu == null &&
        _style.surface == SmartContextMenuSurface.glass &&
        !(MediaQuery.maybeHighContrastOf(context) ?? false);
    if (loadGlass && !_loadGlass) unawaited(_shader.prepare());
    _loadGlass = loadGlass;
  }

  @override
  Widget build(BuildContext context) {
    // Keep the child's state when the panel switches rendering paths.
    final child = KeyedSubtree(key: _childKey, child: widget.child);
    if (!_loadGlass) return _buildSurface(context, _menu?.glass, child);

    return StreamBuilder<void>(
      stream: _shader.ready,
      builder: (context, _) => _buildSurface(
        context,
        _shader.resolveReady(_style.glassStyle, context),
        child,
      ),
    );
  }

  Widget _buildSurface(
    BuildContext context,
    SmartContextMenuResolvedGlass? glass,
    Widget child,
  ) {
    final radius = widget.borderRadius ?? _style.borderRadius;
    if (glass == null) return _buildStandard(context, radius, child);

    return SizedBox(
      width: widget.width,
      child: SmartContextMenuGlassSurface(
        program: glass.program,
        opacity: widget.opacity,
        borderRadius: radius,
        shadows: _style.menuShadows,
        style: glass.style,
        child: child,
      ),
    );
  }

  Widget _buildStandard(
    BuildContext context,
    BorderRadiusGeometry radius,
    Widget child,
  ) {
    final standard = _style.standardStyle;
    final decoration = standard.decoration;
    final blur = standard.blur;
    Widget surface = Container(
      width: widget.width,
      decoration:
          decoration ??
          BoxDecoration(
            color: CupertinoDynamicColor.resolve(standard.color, context),
            borderRadius: radius,
          ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
    if (blur != null) {
      surface = ClipRRect(borderRadius: radius, child: surface);
    }
    if (decoration == null) {
      final border = standard.border.copyWith(
        color: CupertinoDynamicColor.resolve(standard.border.color, context),
      );
      final hasBorder = border.style != BorderStyle.none && border.color.a > 0;
      if (hasBorder) {
        // The outline sits above the contents and outside the backdrop clip.
        surface = DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.fromBorderSide(border),
          ),
          child: surface,
        );
      }
      if (standard.showEdgeHighlight) {
        surface = CustomPaint(
          foregroundPainter: SmartContextMenuHighlightPainter(
            borderRadius: radius.resolve(Directionality.of(context)),
            border: hasBorder ? border : const BorderSide(),
            brightness: CupertinoTheme.brightnessOf(context),
            lightDirection: standard.lightDirection,
          ),
          child: surface,
        );
      }
    }
    final opacity = widget.opacity;
    if (blur == null) {
      return FadeTransition(
        opacity: opacity,
        child: SmartContextMenuShadowBox(
          borderRadius: radius,
          shadows: _style.menuShadows,
          child: surface,
        ),
      );
    }

    // The backdrop samples the same scene during the visibility animation.
    return Stack(
      children: [
        Positioned.fill(
          child: SmartContextMenuShadowBox(
            borderRadius: radius,
            shadows: _style.menuShadows,
            opacity: opacity,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: opacity,
            child: const SizedBox.expand(),
            builder: (context, child) => SmartContextMenuBlurBox(
              blur: blur,
              borderRadius: radius,
              strength: opacity.value,
              child: child!,
            ),
          ),
        ),
        FadeTransition(opacity: opacity, child: surface),
      ],
    );
  }
}

/// The surface and style selected for an open menu and its header panels.
final class SmartContextMenuPanelScope extends InheritedWidget {
  final SmartContextMenuStyle style;
  final SmartContextMenuResolvedGlass? glass;

  const SmartContextMenuPanelScope({
    super.key,
    required this.style,
    required this.glass,
    required super.child,
  });

  static SmartContextMenuPanelScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SmartContextMenuPanelScope>();

  @override
  bool updateShouldNotify(SmartContextMenuPanelScope oldWidget) =>
      style != oldWidget.style || glass != oldWidget.glass;
}
