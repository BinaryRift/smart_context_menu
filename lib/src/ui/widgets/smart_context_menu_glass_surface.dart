import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_glass_style.dart';
import 'smart_context_menu_shadow_box.dart';

/// Clips the shared surface for the entire level switcher.
final class SmartContextMenuGlassSurface extends StatelessWidget {
  final ui.FragmentProgram program;
  final Animation<double> opacity;
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow> shadows;
  final SmartContextMenuGlassStyle style;
  final Widget child;

  const SmartContextMenuGlassSurface({
    super.key,
    required this.program,
    required this.opacity,
    required this.borderRadius,
    required this.shadows,
    required this.style,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final clipper = SmartContextMenuGlassClipper(
      borderRadius.resolve(Directionality.of(context)),
    );
    final border = style.border;
    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) => SmartContextMenuShadowBox(
              borderRadius: clipper.radiusFor(constraints.biggest),
              shadows: shadows,
              opacity: opacity,
              child: const SizedBox.expand(),
            ),
          ),
        ),
        _GlassBackdrop(
          program: program,
          opacity: opacity,
          clipper: clipper,
          style: style,
          pixelRatio: View.of(context).devicePixelRatio,
          child: FadeTransition(opacity: opacity, child: child),
        ),
        if (border.style != BorderStyle.none &&
            border.color.a > 0 &&
            border.width >= 0 &&
            border.width <= _maxFloat32 &&
            border.strokeInset.abs() <= _maxFloat32 &&
            border.strokeOutset.abs() <= _maxFloat32)
          Positioned.fill(
            child: IgnorePointer(
              child: FadeTransition(
                opacity: opacity,
                child: LayoutBuilder(
                  builder: (context, constraints) => DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: clipper.radiusFor(constraints.biggest),
                      border: Border.fromBorderSide(border),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The circular per-corner geometry shared by the glass and its decorations.
final class SmartContextMenuGlassClipper extends CustomClipper<RRect> {
  final BorderRadius borderRadius;

  const SmartContextMenuGlassClipper(this.borderRadius);

  /// Uses the smaller component of each elliptical radius and limits every
  /// corner to half of the shorter side. Negative and non-finite components
  /// become zero, except positive infinity, which takes the limit.
  BorderRadius radiusFor(Size size) {
    // The shader's distance field assumes each corner stays in its quadrant.
    final shortestSide = size.shortestSide;
    final limit = shortestSide.isFinite ? math.max(0.0, shortestSide / 2) : 0.0;
    double component(double value) => value.isNaN ? 0 : value.clamp(0.0, limit);
    Radius circular(Radius radius) =>
        Radius.circular(math.min(component(radius.x), component(radius.y)));
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

const _transformTolerance = 1e-6;
const _maxFloat32 = 3.4028234663852886e38;

/// Converts a non-negative style value to a finite shader uniform.
@visibleForTesting
double glassShaderNonnegativeFloat(double value) {
  if (!value.isFinite || value <= 0) return 0;
  return math.min(value, _maxFloat32);
}

/// Normalizes the light direction before writing the shader uniform.
@visibleForTesting
Offset glassShaderLightDirection(Offset direction) {
  final scale = math.max(direction.dx.abs(), direction.dy.abs());
  if (!scale.isFinite || scale == 0) return Offset.zero;
  // Scale first so computing the length works for any finite input.
  final scaled = direction / scale;
  return scaled / scaled.distance;
}

/// Maps local logical pixels to physical backdrop pixels.
///
/// Returns null unless [size] and [pixelRatio] are finite and positive and
/// [transform] only translates and scales each axis by a positive factor.
@visibleForTesting
({Offset origin, Offset scale})? glassBackdropMapping(
  Matrix4 transform,
  Size size,
  double pixelRatio,
) {
  if (!size.isFinite || size.width <= 0 || size.height <= 0) return null;
  if (!pixelRatio.isFinite || pixelRatio <= 0) return null;

  final m = transform.storage;
  bool near(double value, double target) =>
      (value - target).abs() <= _transformTolerance;
  // Rotation, skew and perspective would bend the panel away from the
  // axis-aligned contour the shader draws.
  if (!near(m[1], 0) ||
      !near(m[4], 0) ||
      !near(m[3], 0) ||
      !near(m[7], 0) ||
      !near(m[15], 1)) {
    return null;
  }
  // Rejects collapsed and mirrored axes.
  if (!(m[0] > _transformTolerance) || !(m[5] > _transformTolerance)) {
    return null;
  }

  final origin = Offset(m[12], m[13]) * pixelRatio;
  final scale = Offset(m[0], m[5]) * pixelRatio;
  if (!origin.isFinite || !scale.isFinite) return null;
  return (origin: origin, scale: scale);
}

/// Aligns the backdrop capture to physical pixels in the filter's local space.
@visibleForTesting
RRect glassBackdropClip(
  RRect clip, {
  required Offset origin,
  required Offset scale,
}) {
  // Stay just above the pixel boundary so float32 rounding in Impeller
  // cannot make an integral edge alternate between two capture origins.
  const pixelBias = 0.02;
  double align(double edge, double origin, double scale) {
    final pixel = origin + edge * scale;
    return (pixel.roundToDouble() + pixelBias - origin) / scale;
  }

  final rect = Rect.fromLTRB(
    align(clip.left, origin.dx, scale.dx),
    align(clip.top, origin.dy, scale.dy),
    align(clip.right, origin.dx, scale.dx),
    align(clip.bottom, origin.dy, scale.dy),
  );
  if (!rect.isFinite || rect.isEmpty) return clip;
  return RRect.fromRectAndCorners(
    rect,
    topLeft: clip.tlRadius,
    topRight: clip.trRadius,
    bottomRight: clip.brRadius,
    bottomLeft: clip.blRadius,
  );
}

final class _GlassBackdrop extends SingleChildRenderObjectWidget {
  final ui.FragmentProgram program;
  final Animation<double> opacity;
  final SmartContextMenuGlassClipper clipper;
  final SmartContextMenuGlassStyle style;
  final double pixelRatio;

  const _GlassBackdrop({
    required this.program,
    required this.opacity,
    required this.clipper,
    required this.style,
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
  Offset _paintOffset = Offset.zero;

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
    _paintOffset = offset;
    final backdrop = (layer ??= _GlassLayer(this)) as _GlassLayer;
    context.pushLayer(backdrop, super.paint, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) =>
      _settings.clipper.getClip(size).contains(position) &&
      super.hitTest(result, position: position);

  @override
  Rect describeApproximatePaintClip(RenderObject child) => Offset.zero & size;

  ui.ImageFilter? _filter(
    double opacity,
    Offset origin,
    Offset scale,
    RRect clip,
  ) {
    if (!ui.ImageFilter.isShaderFilterSupported) return null;

    final style = _settings.style;
    final tint = style.color;
    final light = glassShaderLightDirection(style.lightDirection);

    // Impeller provides the texture size (floats 0–1) and sampler 0.
    // The remaining slots follow smart_context_menu_glass.frag.
    _shader
      ..setFloat(2, origin.dx)
      ..setFloat(3, origin.dy)
      ..setFloat(4, scale.dx)
      ..setFloat(5, scale.dy)
      ..setFloat(6, size.width)
      ..setFloat(7, size.height)
      ..setFloat(8, clip.tlRadiusX)
      ..setFloat(9, clip.trRadiusX)
      ..setFloat(10, clip.brRadiusX)
      ..setFloat(11, clip.blRadiusX)
      ..setFloat(12, opacity)
      ..setFloat(13, tint.r)
      ..setFloat(14, tint.g)
      ..setFloat(15, tint.b)
      ..setFloat(16, tint.a)
      ..setFloat(17, glassShaderNonnegativeFloat(style.refraction))
      ..setFloat(18, glassShaderNonnegativeFloat(style.edgeHighlight))
      ..setFloat(19, glassShaderNonnegativeFloat(style.rimWidth))
      ..setFloat(20, glassShaderNonnegativeFloat(style.bevelWidth))
      ..setFloat(21, light.dx)
      ..setFloat(22, light.dy);
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
  ui.BackdropFilterEngineLayer? _blurEngineLayer;
  ui.BackdropFilterEngineLayer? _shaderEngineLayer;

  _GlassLayer(this.backdrop);

  @override
  bool get alwaysNeedsAddToScene => true;

  @override
  void addToScene(ui.SceneBuilder builder) {
    final settings = backdrop._settings;
    final opacity = settings.opacity.value;
    if (opacity <= 0 || backdrop.size.isEmpty) return;

    // Read the final transform here because a retained ancestor layer can
    // move without repainting the backdrop.
    final mapping = glassBackdropMapping(
      backdrop.getTransformTo(null),
      backdrop.size,
      settings.pixelRatio,
    );
    final clip = settings.clipper.getClip(backdrop.size);
    final filter = mapping == null
        ? null
        : backdrop._filter(opacity, mapping.origin, mapping.scale, clip);
    final captureClip = mapping == null
        ? clip
        : glassBackdropClip(clip, origin: mapping.origin, scale: mapping.scale);
    engineLayer = builder.pushClipRRect(
      captureClip.shift(backdrop._paintOffset),
      clipBehavior: ui.Clip.antiAlias,
      oldLayer: engineLayer as ui.ClipRRectEngineLayer?,
    );

    if (filter == null) {
      // Keep the content visible and resume the glass on a later frame.
      _blurEngineLayer?.dispose();
      _blurEngineLayer = null;
      _shaderEngineLayer?.dispose();
      _shaderEngineLayer = null;
      addChildrenToScene(builder);
      builder.pop();
      return;
    }

    final sigma = settings.style.blur.sigmaX * opacity;
    final oldBlurLayer = _blurEngineLayer;
    _blurEngineLayer = sigma.isFinite && sigma > 0
        ? builder.pushBackdropFilter(
            ui.ImageFilter.blur(
              sigmaX: sigma,
              sigmaY: sigma,
              tileMode: ui.TileMode.clamp,
            ),
            oldLayer: oldBlurLayer,
          )
        : null;
    oldBlurLayer?.dispose();
    // Finish the blur pass so refraction samples the blurred backdrop.
    if (_blurEngineLayer != null) builder.pop();

    final oldShaderLayer = _shaderEngineLayer;
    _shaderEngineLayer = builder.pushBackdropFilter(
      filter,
      oldLayer: oldShaderLayer,
    );
    oldShaderLayer?.dispose();
    addChildrenToScene(builder);
    builder
      ..pop()
      ..pop();
  }

  @override
  void dispose() {
    _blurEngineLayer?.dispose();
    _shaderEngineLayer?.dispose();
    super.dispose();
  }
}
