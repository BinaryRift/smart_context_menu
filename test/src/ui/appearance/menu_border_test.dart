import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  List<Decoration> foregroundsOf(WidgetTester tester) => [
    for (final container in tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    ))
      ?container.foregroundDecoration,
  ];

  testWidgets('is painted over the menu content', (tester) async {
    await tester.pumpMenu(
      items: appearanceItems(),
      brightness: Brightness.light,
    );
    await tester.openMenu();

    final foregrounds = foregroundsOf(tester);
    expect(foregrounds, hasLength(1));
    final border = (foregrounds.single as BoxDecoration).border! as Border;
    expect(
      border.top.color,
      isSameColorAs(light(SmartContextMenuDefaults.borderColor)),
    );
  });

  testWidgets('is not added to a custom decoration', (tester) async {
    await tester.pumpMenu(
      items: appearanceItems(),
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          menuDecoration: BoxDecoration(color: Color(0xFF000001)),
        ),
      ),
    );
    await tester.openMenu();

    expect(foregroundsOf(tester), isEmpty);
  });
}
