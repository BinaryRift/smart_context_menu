import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_glass_surface.dart';

void main() {
  test('matches all four circular radii to the surface size', () {
    const clipper = SmartContextMenuGlassClipper(
      BorderRadius.only(
        topLeft: Radius.elliptical(42, 16),
        topRight: Radius.zero,
        bottomRight: Radius.circular(140),
        bottomLeft: Radius.elliptical(9, 30),
      ),
    );

    final shortClip = clipper.getClip(const Size(250, 80));
    expect(shortClip.tlRadius, const Radius.circular(16));
    expect(shortClip.trRadius, Radius.zero);
    expect(shortClip.brRadius, const Radius.circular(40));
    expect(shortClip.blRadius, const Radius.circular(9));

    final tallClip = clipper.getClip(const Size(250, 180));
    expect(tallClip.brRadius, const Radius.circular(90));

    final narrowClip = clipper.getClip(const Size(40, 180));
    expect(narrowClip.brRadius, const Radius.circular(20));
  });

  test('keeps the physical corners after resolving a directional radius', () {
    const radius = BorderRadiusDirectional.only(
      topStart: Radius.circular(25),
      bottomEnd: Radius.circular(9),
    );
    final clipper = SmartContextMenuGlassClipper(
      radius.resolve(TextDirection.rtl),
    );

    final clip = clipper.getClip(const Size(200, 100));
    expect(clip.tlRadius, Radius.zero);
    expect(clip.trRadius, const Radius.circular(25));
    expect(clip.brRadius, Radius.zero);
    expect(clip.blRadius, const Radius.circular(9));
  });

  test('turns invalid radius components into a finite contour', () {
    const clipper = SmartContextMenuGlassClipper(
      BorderRadius.only(
        topLeft: Radius.elliptical(-12, 30),
        topRight: Radius.circular(double.nan),
        bottomRight: Radius.circular(double.infinity),
        bottomLeft: Radius.elliptical(double.negativeInfinity, 8),
      ),
    );

    final radius = clipper.radiusFor(const Size(200, 60));
    expect(radius.topLeft, Radius.zero);
    expect(radius.topRight, Radius.zero);
    expect(radius.bottomRight, const Radius.circular(30));
    expect(radius.bottomLeft, Radius.zero);
  });

  test('keeps every corner at zero on an empty or unbounded size', () {
    const clipper = SmartContextMenuGlassClipper(
      BorderRadius.all(Radius.circular(20)),
    );

    expect(clipper.radiusFor(Size.zero), BorderRadius.zero);
    expect(clipper.radiusFor(Size.infinite), BorderRadius.zero);
  });
}
