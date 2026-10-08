import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
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

  testWidgets('keeps the shadows with a custom decoration', (tester) async {
    const shadows = [BoxShadow(color: Color(0xFF000001), blurRadius: 3)];
    await tester.pumpMenu(
      items: appearanceItems(),
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          menuShadows: shadows,
          menuDecoration: BoxDecoration(color: Color(0xFF000002)),
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
}
