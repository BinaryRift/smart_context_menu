import 'dart:async' show unawaited;
import 'dart:ui' show ImageFilter;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_blur_box.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_shadow_box.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  List<BoxShadow>? shadowsOf(WidgetTester tester) {
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(SmartContextMenuShadowBox),
            matching: find.byType(Container),
          )
          .first,
    );
    return (container.decoration! as BoxDecoration).boxShadow;
  }

  testWidgets('uses the default shadows', (tester) async {
    await tester.pumpMenu(items: appearanceItems());
    await tester.openMenu();

    expect(shadowsOf(tester), SmartContextMenuDefaults.menuShadows);
  });

  testWidgets('applies the style shadows', (tester) async {
    const shadows = [BoxShadow(color: Color(0xFF000001), blurRadius: 3)];
    await tester.pumpMenu(
      items: appearanceItems(),
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(menuShadows: shadows),
      ),
    );
    await tester.openMenu();

    expect(shadowsOf(tester), shadows);
  });

  testWidgets('resolves dynamic shadow colors for the theme', (tester) async {
    const color = CupertinoDynamicColor.withBrightness(
      color: Color(0xFF000001),
      darkColor: Color(0xFF000002),
    );
    await tester.pumpMenu(
      items: appearanceItems(),
      brightness: Brightness.dark,
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          menuShadows: [
            BoxShadow(
              color: color,
              offset: Offset(1, 2),
              blurRadius: 3,
              spreadRadius: 4,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
      ),
    );
    await tester.openMenu();

    final shadow = shadowsOf(tester)!.single;
    expect(shadow.color.toARGB32(), color.darkColor.toARGB32());
    expect(shadow.offset, const Offset(1, 2));
    expect(shadow.blurRadius, 3);
    expect(shadow.spreadRadius, 4);
    expect(shadow.blurStyle, BlurStyle.outer);
  });

  testWidgets('keeps the shadows with a custom decoration', (tester) async {
    const shadows = [BoxShadow(color: Color(0xFF000001), blurRadius: 3)];
    await tester.pumpMenu(
      items: appearanceItems(),
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          menuShadows: shadows,
          standardStyle: SmartContextMenuStandardStyle(
            decoration: BoxDecoration(color: Color(0xFF000002)),
          ),
        ),
      ),
    );
    await tester.openMenu();

    expect(shadowsOf(tester), shadows);
  });

  testWidgets('draws no shadows with an empty list', (tester) async {
    await tester.pumpMenu(
      items: appearanceItems(),
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(menuShadows: []),
      ),
    );
    await tester.openMenu();

    expect(shadowsOf(tester), isEmpty);
  });

  testWidgets('fades Standard shadows without fading the backdrop layer', (
    tester,
  ) async {
    const blur = SmartContextMenuBlur.extraStrong;
    const shadow = BoxShadow(color: Color(0x7322D3EE), blurRadius: 48);
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);
    await tester.pumpMenu(
      items: appearanceItems(),
      controller: controller,
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          surface: SmartContextMenuSurface.standard,
          standardStyle: SmartContextMenuStandardStyle(blur: blur),
          menuShadows: [shadow],
        ),
      ),
    );

    final blurBox = find.byType(SmartContextMenuBlurBox);
    final backdrop = find.descendant(
      of: blurBox,
      matching: find.byType(BackdropFilter),
    );
    final shadowFade = find.descendant(
      of: find.byType(SmartContextMenuShadowBox),
      matching: find.byType(ColorFiltered),
    );
    unawaited(controller.open());
    for (var i = 0; i < 5 && blurBox.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 120));

    final route = ModalRoute.of(tester.element(backdrop))!;
    final openingOpacity = route.animation!.value;
    expect(openingOpacity, allOf(greaterThan(0), lessThan(1)));
    expect(shadowFade, findsOneWidget);
    expect(
      find.ancestor(of: backdrop, matching: find.byType(FadeTransition)),
      findsNothing,
    );
    expect(
      tester.widget<BackdropFilter>(backdrop).filter,
      ImageFilter.blur(
        sigmaX: blur.sigmaX * openingOpacity,
        sigmaY: blur.sigmaY * openingOpacity,
      ),
    );

    await tester.pumpAndSettle();
    expect(shadowFade, findsNothing);
    expect(
      tester.widget<BackdropFilter>(backdrop).filter,
      ImageFilter.blur(sigmaX: blur.sigmaX, sigmaY: blur.sigmaY),
    );
    expect(shadowsOf(tester), [shadow]);

    final closed = controller.close();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final closingOpacity = route.animation!.value;
    expect(closingOpacity, allOf(greaterThan(0), lessThan(1)));
    expect(shadowFade, findsOneWidget);
    expect(
      tester.widget<SmartContextMenuBlurBox>(blurBox).strength,
      closingOpacity,
    );
    await tester.pumpAndSettle();
    await closed;
  });
}
