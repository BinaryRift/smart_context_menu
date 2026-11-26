import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'smart_context_menu_shadow_box.dart';

/// Clips the shared surface for the entire level switcher.
final class SmartContextMenuGlassSurface extends StatelessWidget {
  final ui.FragmentProgram program;
  final Animation<double> opacity;
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow> shadows;
  final Color tint;
  final Widget child;

  const SmartContextMenuGlassSurface({
    super.key,
    required this.program,
    required this.opacity,
    required this.borderRadius,
    required this.shadows,
    required this.tint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final clipper = SmartContextMenuGlassClipper(
      borderRadius.resolve(Directionality.of(context)),
    );
    return Stack(
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: opacity,
            child: LayoutBuilder(
              builder: (context, constraints) => SmartContextMenuShadowBox(
                borderRadius: clipper.radiusFor(constraints.biggest),
                shadows: shadows,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        ClipRRect(
          clipper: clipper,
          child: _GlassBackdrop(
            program: program,
            opacity: opacity,
            clipper: clipper,
            tint: tint,
            pixelRatio: View.of(context).devicePixelRatio,
            child: FadeTransition(opacity: opacity, child: child),
          ),
        ),
      ],
    );
  }
}

/// The circular per-corner geometry shared by the glass filter, clip and shadow.
final class SmartContextMenuGlassClipper extends CustomClipper<RRect> {
  final BorderRadius borderRadius;

  const SmartContextMenuGlassClipper(this.borderRadius);

  BorderRadius radiusFor(Size size) {
    // The shader's distance field assumes each corner stays in its quadrant.
    final limit = size.shortestSide / 2;
    Radius circular(Radius radius) =>
        Radius.circular(math.min(radius.x, radius.y).clamp(0.0, limit));
    return BorderRadius.only(
      topLeft: circular(borderRadius.topLeft),
      topRight: circular(borderRadius.topRight),
      bottomRight: circular(borderRadius.bottomRight),
      bottomLeft: circular(borderRadius.bottomLeft),
    );
  }

  @override
  RRect getClip(Size size) => radiusFor(size).toRRect(Offset.zero & size);

  @override
  bool shouldReclip(SmartContextMenuGlassClipper oldClipper) =>
      borderRadius != oldClipper.borderRadius;
}

final class _GlassBackdrop extends SingleChildRenderObjectWidget {
  final ui.FragmentProgram program;
  final Animation<double> opacity;
  final SmartContextMenuGlassClipper clipper;
  final Color tint;
  final double pixelRatio;

  const _GlassBackdrop({
    required this.program,
    required this.opacity,
    required this.clipper,
    required this.tint,
    required this.pixelRatio,
    required super.child,
  });

  @override
  _RenderGlassBackdrop createRenderObject(BuildContext context) =>
      _RenderGlassBackdrop(this);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderGlassBackdrop renderObject,
  ) => renderObject.update(this);
}

final class _RenderGlassBackdrop extends RenderProxyBox {
  _GlassBackdrop _settings;
  ui.FragmentShader _shader;

  _RenderGlassBackdrop(this._settings)
    : _shader = _settings.program.fragmentShader();

  @override
  bool get alwaysNeedsCompositing => true;

  void update(_GlassBackdrop settings) {
    if (_settings.program != settings.program) {
      _shader.dispose();
      _shader = settings.program.fragmentShader();
    }
    _settings = settings;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final backdrop = (layer ??= _GlassLayer(this)) as _GlassLayer;
    context.pushLayer(backdrop, super.paint, offset);
  }

  ui.ImageFilter _filter(double opacity) {
    // Menu scale and stretch are axis-aligned. Read their final transform
    // here because a retained ancestor layer can move without repainting us.
    final transform = getTransformTo(null).storage;
    final pixelRatio = _settings.pixelRatio;
    final tint = _settings.tint;
    final radius = _settings.clipper.radiusFor(size);

    // Impeller provides the texture size (floats 0–1) and sampler 0.
    // The remaining slots follow smart_context_menu_glass.frag.
    _shader
      ..setFloat(2, transform[12] * pixelRatio)
      ..setFloat(3, transform[13] * pixelRatio)
      ..setFloat(4, transform[0] * pixelRatio)
      ..setFloat(5, transform[5] * pixelRatio)
      ..setFloat(6, size.width)
      ..setFloat(7, size.height)
      ..setFloat(8, radius.topLeft.x)
      ..setFloat(9, radius.topRight.x)
      ..setFloat(10, radius.bottomRight.x)
      ..setFloat(11, radius.bottomLeft.x)
      ..setFloat(12, opacity)
      ..setFloat(13, tint.r)
      ..setFloat(14, tint.g)
      ..setFloat(15, tint.b)
      ..setFloat(16, tint.a);
    return ui.ImageFilter.shader(_shader);
  }

  @override
  void dispose() {
    _shader.dispose();
    super.dispose();
  }
}

final class _GlassLayer extends ContainerLayer {
  final _RenderGlassBackdrop backdrop;

  _GlassLayer(this.backdrop);

  @override
  bool get alwaysNeedsAddToScene => true;

  @override
  void addToScene(ui.SceneBuilder builder) {
    final opacity = backdrop._settings.opacity.value;
    if (opacity <= 0 || backdrop.size.isEmpty) return;

    engineLayer = builder.pushBackdropFilter(
      backdrop._filter(opacity),
      oldLayer: engineLayer as ui.BackdropFilterEngineLayer?,
    );
    addChildrenToScene(builder);
    builder.pop();
  }
}
