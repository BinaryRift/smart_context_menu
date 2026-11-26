#include <flutter/runtime_effect.glsl>

precision highp float;

// Liquid glass backdrop filter for smart_context_menu.
//
// The material combines rounded-edge refraction, center magnification,
// a translucent tint and directional reflections. Geometry is evaluated
// in local logical pixels; the backdrop is sampled in texture space.
//
// Integration: use ImageFilter.shader() with an external rounded-rectangle
// clip. The input backdrop is assumed opaque. The coordinate mapping
// supports positive axis-aligned scale and translation.
//
// Float slots 0-1 and sampler slot 0 are supplied by Flutter Engine.
// The remaining float slots must be populated by the host before rendering.
uniform vec2 u_backdropSize; // 0-1: input texture dimensions in pixels.
uniform vec2 u_origin;       // 2-3: surface origin in backdrop pixel coordinates.
uniform vec2 u_scale;        // 4-5: backdrop pixels per local logical pixel (XY).
uniform vec2 u_size;         // 6-7: surface dimensions in logical pixels.
// 8-11: circular corner radii in logical pixels, ordered TL, TR, BR, BL.
// Convert elliptical radii to min(x, y) on the host and clamp each radius
// to half the shorter side. Use the same geometry for the external clip.
uniform vec4 u_radii;
uniform float u_opacity;     // 12: overall surface opacity in [0, 1].
uniform vec4 u_tint;         // 13-16: unpremultiplied RGBA tint in [0, 1].
uniform float u_refraction;  // 17: refraction and magnification multiplier.
uniform float u_edgeHighlight; // 18: edge reflection multiplier.
uniform sampler2D u_backdrop; // Sampler 0: input backdrop texture.

out vec4 fragColor;

// Optical parameters. Distances are expressed in local logical pixels.
const float kBevelWidth = 24.0;
const float kTravelDepth = 24.0;
const float kIOR = 1.28;
const float kMagnification = 1.03;

// Bounds ray displacement relative to the bevel width to mitigate sampling
// folds. This limit depends on the refractive index and displacement taper.
const float kMaxTravelToBevel = 1.03;

// Rim lighting: ambient edge reflection and two opposing directional lobes.
const float kRimWidth = 5.8;
const float kRimBaseLight = 0.10;
const float kRimBaseDark = 0.035;
const float kRimStrengthLight = 0.78;
const float kRimStrengthDark = 0.45;
const float kSecondaryArc = 0.42;
const vec2 kLightDirection = vec2(-0.6, -0.8);

// Fresnel-weighted reflection shoulder within the optical bevel.
const float kShoulderWidth = 5.0;
const float kShoulderLight = 0.075;
const float kShoulderDark = 0.045;

// Interpolates bevel width between the tangency points of a straight edge.
// The distance to adjacent outer sides bounds the width to limit refraction
// near transitions between closest-edge normals.
float edgeBevel(float position, float halfExtent,
                float startRadius, float endRadius) {
  float span = 2.0 * halfExtent - startRadius - endRadius;
  float startBevel = min(kBevelWidth, startRadius);
  float endBevel = min(kBevelWidth, endRadius);
  // Under the half-side radius constraint, a collapsed segment has equal
  // endpoint radii. The epsilon prevents division by zero.
  float t = clamp((position + halfExtent - startRadius) /
                  max(span, 1e-5), 0.0, 1.0);
  t = t * t * (3.0 - 2.0 * t);
  return min(mix(startBevel, endBevel, t),
             max(halfExtent - abs(position), 0.0));
}

float opticalBevel(vec2 p, vec2 halfSize, vec4 radii,
                   float radius, vec2 corner, vec2 normal) {
  float bevel = min(kBevelWidth, radius);
  // Equal radii use a constant bevel without edge interpolation.
  if (all(equal(radii, vec4(radii.x)))) return bevel;

  // In circular corners, the bevel is bounded by the corner radius.
  if (corner.x > 0.0 && corner.y > 0.0) return bevel;

  // Select the straight edge from its normal and interpolate between its
  // adjacent corner radii.
  if (abs(normal.y) > abs(normal.x)) {
    return p.y < 0.0
        ? edgeBevel(p.x, halfSize.x, radii.x, radii.y)
        : edgeBevel(p.x, halfSize.x, radii.w, radii.z);
  }
  return p.x < 0.0
      ? edgeBevel(p.y, halfSize.y, radii.x, radii.w)
      : edgeBevel(p.y, halfSize.y, radii.y, radii.z);
}

void main() {
  vec2 fragment = FlutterFragCoord().xy;
  vec2 halfSize = u_size * 0.5;
  vec2 p = (fragment - u_origin) / u_scale - halfSize;

  // Evaluate the per-corner rounded-rectangle signed distance field (SDF).
  // The half-side constraint keeps quadrant selection valid. The host clip
  // must use the same effective radii.
  vec4 radii = clamp(u_radii, 0.0, min(halfSize.x, halfSize.y));
  vec2 rightBottom = step(vec2(0.0), p);
  float radius = mix(mix(radii.x, radii.y, rightBottom.x),
                     mix(radii.w, radii.z, rightBottom.x), rightBottom.y);
  vec2 q = abs(p) - halfSize + radius;
  vec2 corner = max(q, 0.0);
  float cornerLength = length(corner);
  float distance = cornerLength + min(max(q.x, q.y), 0.0) - radius;
  float depth = max(-distance, 0.0);

  // Outward SDF normal with deterministic handling of axis and tie cases.
  vec2 direction = mix(vec2(-1.0), vec2(1.0), step(vec2(0.0), p));
  vec2 normal = cornerLength > 1e-5
      ? direction * (corner / cornerLength)
      : (q.x > q.y ? vec2(direction.x, 0.0) : vec2(0.0, direction.y));

  // Refraction is confined to the optical bevel. Zero-width bevels leave
  // only magnification, tint and rim lighting.
  float bevel = opticalBevel(p, halfSize, radii, radius, corner, normal);
  vec2 refractionShift = vec2(0.0);
  float h = 1.0;

  if (bevel > 1e-4 && depth < bevel) {
    h = clamp(depth / bevel, 0.0, 1.0);

    // Lift the 2D boundary normal onto a rounded 3D optical surface.
    float bulge = sqrt(max(1.0 - h * h, 0.0));
    vec3 surfaceNormal = vec3(normal * bulge, h);
    vec2 ray = refract(vec3(0.0, 0.0, -1.0), surfaceNormal,
                       1.0 / kIOR).xy;

    // Taper displacement to zero at the flat interior and limit travel
    // relative to bevel width to reduce sampling-map distortion.
    float maxTravel = bevel * kMaxTravelToBevel;
    // Bound the multiplier before multiplying, even for extreme uniforms.
    float travel = min(kTravelDepth * min(u_refraction, maxTravel / kTravelDepth),
                       maxTravel);
    refractionShift = ray * travel * (1.0 - h * h);
  }

  // Combine local optical offsets and convert to backdrop texture coordinates.
  float magnification = 1.0 + (kMagnification - 1.0) * u_refraction;
  vec2 magnificationShift = p / magnification - p;
  vec2 samplePosition = fragment + (magnificationShift + refractionShift) * u_scale;
  vec2 uv = samplePosition / u_backdropSize;

  // Account for backend-dependent orientation of the input texture.
#if !defined(IMPELLER_OPENGLES_UNFLIPPED_DEPRECATED)
#if defined(IMPELLER_TARGET_OPENGLES)
  uv.y = 1.0 - uv.y;
#elif defined(IMPELLER_GRAPHICS_BACKEND)
  if (dFdy(fragment.y) < 0.0) uv.y = 1.0 - uv.y;
#endif
#endif

  // Clamp sampling to texel centers at the texture boundary.
  vec2 halfTexel = 0.5 / u_backdropSize;
  vec3 backdrop = texture(u_backdrop, clamp(uv, halfTexel, 1.0 - halfTexel)).rgb;
  vec3 glass = mix(backdrop, u_tint.rgb, u_tint.a);

  // Fifth-power rim falloff and directional lighting in backdrop space.
  float rim = pow(clamp(1.0 + (distance + 0.35) / kRimWidth, 0.0, 1.0), 5.0);
  vec2 surfaceDirection = normal / u_scale;
  surfaceDirection /= max(length(surfaceDirection), 1e-5);
  float facing = dot(surfaceDirection, kLightDirection);
  float arc = facing * facing * (facing < 0.0 ? kSecondaryArc : 1.0);
  // Estimate material darkness from tint luminance and alpha. The alpha
  // gate prevents a nearly transparent tint from strongly suppressing light.
  float tintLuma = dot(u_tint.rgb, vec3(0.2126, 0.7152, 0.0722));
  float darkMaterial = (1.0 - smoothstep(0.10, 0.50, tintLuma))
                       * smoothstep(0.15, 0.65, u_tint.a);

  // Dark materials attenuate ambient rim lighting more than directional light.
  float baseReflection = mix(kRimBaseLight, kRimBaseDark, darkMaterial);
  float directionalReflection = mix(kRimStrengthLight, kRimStrengthDark, darkMaterial);
  float highlight = rim * (baseReflection + directionalReflection * arc);

  // Add a Schlick Fresnel-weighted shoulder inside the bevel.
  if (bevel > 1e-4 && depth < bevel) {
    float shoulderStrength = mix(kShoulderLight, kShoulderDark, darkMaterial);
    float f0 = (kIOR - 1.0) / (kIOR + 1.0);
    f0 *= f0;
    float fresnel = f0 + (1.0 - f0) * pow(1.0 - h, 5.0);
    float shoulder = 1.0 - smoothstep(0.0, min(kShoulderWidth, bevel), depth);
    highlight += shoulderStrength * shoulder * arc * (0.35 + 0.65 * fresnel);
  }

  glass = mix(glass, vec3(1.0), clamp(highlight * u_edgeHighlight, 0.0, 1.0));

  // Premultiplied RGBA output for an opaque input backdrop. The external
  // clip defines coverage; u_opacity scales both RGB and alpha.
  fragColor = vec4(glass, 1.0) * u_opacity;
}
