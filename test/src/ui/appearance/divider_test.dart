import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  const style = SmartContextMenuStyle(
    dividerColor: Color(0xFF000001),
    dividerThickness: 2,
    dividerIndent: 8,
    dividerEndIndent: 4,
  );

  testWidgets('uses the default divider', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'First', hasDivider: true),
        SmartContextMenuItem.simple(title: 'Second'),
      ],
      brightness: Brightness.light,
    );
    await tester.openMenu();

    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.thickness, SmartContextMenuDefaults.dividerThickness);
    expect(divider.height, SmartContextMenuDefaults.dividerThickness);
    expect(divider.indent, 0);
    expect(divider.endIndent, 0);
    expect(
      divider.color,
      isSameColorAs(light(SmartContextMenuDefaults.dividerColor)),
    );
  });

  testWidgets('applies the style', (tester) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(style: style),
      items: [
        SmartContextMenuItem.simple(title: 'First', hasDivider: true),
        SmartContextMenuItem.simple(title: 'Second'),
      ],
    );
    await tester.openMenu();

    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.thickness, 2);
    expect(divider.height, 2);
    expect(divider.indent, 8);
    expect(divider.endIndent, 4);
    expect(divider.color, isSameColorAs(style.dividerColor));
  });

  testWidgets('applies the style to the back item', (tester) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(style: style),
      items: submenuItems(),
    );
    await tester.openSubmenu();

    // The back item and its invisible placeholder.
    final dividers = tester.widgetList<Divider>(find.byType(Divider));
    expect(dividers, hasLength(2));
    for (final divider in dividers) {
      expect(divider.thickness, 2);
      expect(divider.indent, 8);
    }
  });
}
