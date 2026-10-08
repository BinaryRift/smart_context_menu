import 'dart:ui' as ui show Image;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_anchor.dart';

void main() {
  const target = Key('target');
  const heroTag = 'hero';

  late ui.Image image;
  ui.Image? snapshot;

  setUp(() => snapshot = null);

  Future<void> pumpAnchor(
    WidgetTester tester, {
    bool isMenuActive = false,
    bool isMenuVisible = false,
  }) {
    return tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SmartContextMenuAnchor(
            previewKey: GlobalKey(),
            contentKey: GlobalKey(),
            heroTag: heroTag,
            snapshot: () => snapshot,
            isMenuActive: isMenuActive,
            isMenuVisible: isMenuVisible,
            child: const SizedBox(key: target, width: 100, height: 50),
          ),
        ),
      ),
    );
  }

  Future<void> createImage(WidgetTester tester) async {
    image = (await tester.runAsync(
      () => createTestImage(width: 10, height: 10),
    ))!;
    addTearDown(image.dispose);
  }

  bool childVisible(WidgetTester tester) => tester
      .widget<Visibility>(
        find.ancestor(
          of: find.byKey(target),
          matching: find.byType(Visibility),
        ),
      )
      .visible;

  testWidgets('shows the child without a hero when the menu is idle', (
    tester,
  ) async {
    await pumpAnchor(tester);

    expect(childVisible(tester), isTrue);
    expect(find.byType(Hero), findsNothing);
  });

  testWidgets('adds an empty hero while the menu opens', (tester) async {
    await createImage(tester);
    snapshot = image;
    await pumpAnchor(tester, isMenuActive: true);

    expect(childVisible(tester), isTrue);
    expect(find.byType(Hero), findsOneWidget);
    expect(find.byType(RawImage), findsNothing);
  });

  testWidgets('hides the child behind the snapshot while the menu is open', (
    tester,
  ) async {
    await createImage(tester);
    snapshot = image;
    await pumpAnchor(tester, isMenuActive: true, isMenuVisible: true);

    expect(childVisible(tester), isFalse);
    expect(
      tester.getSize(find.byType(SmartContextMenuAnchor)),
      const Size(100, 50),
    );
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, same(image));
  });

  testWidgets('the flight shows the snapshot set after the last build', (
    tester,
  ) async {
    await createImage(tester);
    await pumpAnchor(tester, isMenuActive: true);
    snapshot = image;

    final hero = tester.widget<Hero>(find.byType(Hero));
    final context = tester.element(find.byType(Hero));
    final shuttle = hero.flightShuttleBuilder!(
      context,
      const AlwaysStoppedAnimation(0),
      HeroFlightDirection.push,
      context,
      context,
    );

    expect(shuttle, isA<RawImage>());
    expect((shuttle as RawImage).image, same(image));
  });
}
