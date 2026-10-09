import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  testWidgets('uses the default text style', (tester) async {
    await tester.pumpMenu(items: appearanceItems());
    await tester.openMenu();

    expect(
      tester.titleStyleOf('Enabled').fontSize,
      SmartContextMenuDefaults.titleStyle.fontSize,
    );
  });

  testWidgets('applies the text style', (tester) async {
    await tester.pumpMenu(items: appearanceItems(), config: customConfig);
    await tester.openMenu();

    final enabled = tester.titleStyleOf('Enabled');
    expect(enabled.fontFamily, 'Custom');
    expect(enabled.fontSize, 13);
    expect(enabled.color, isSameColorAs(customStyle.titleStyle.color!));
  });

  testWidgets('uses the default text color if the style has none', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: appearanceItems(),
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(titleStyle: TextStyle(fontSize: 13)),
      ),
      brightness: Brightness.light,
    );
    await tester.openMenu();

    final enabled = tester.titleStyleOf('Enabled');
    expect(enabled.fontSize, 13);
    expect(
      enabled.color,
      isSameColorAs(light(SmartContextMenuDefaults.foregroundColor)),
    );
  });

  testWidgets('item title style takes precedence', (tester) async {
    await tester.pumpMenu(
      config: customConfig,
      items: [
        SmartContextMenuItem.simple(
          title: 'Styled',
          titleStyle: const TextStyle(fontSize: 21, color: Color(0xFF0000FF)),
        ),
      ],
    );
    await tester.openMenu();

    final style = tester.titleStyleOf('Styled');
    expect(style.fontSize, 21);
    expect(style.fontFamily, isNull);
    expect(style.color, isSameColorAs(const Color(0xFF0000FF)));
  });

  testWidgets('limits the title lines', (tester) async {
    await tester.pumpMenu(items: appearanceItems());
    await tester.openMenu();
    expect(
      tester.widget<Text>(find.text('Enabled')).maxLines,
      SmartContextMenuDefaults.titleMaxLines,
    );
  });

  testWidgets('applies the title max lines', (tester) async {
    await tester.pumpMenu(
      items: appearanceItems(),
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(titleMaxLines: 1),
      ),
    );
    await tester.openMenu();

    expect(tester.widget<Text>(find.text('Enabled')).maxLines, 1);
  });

  testWidgets('text in leading and trailing takes the title style', (
    tester,
  ) async {
    await tester.pumpMenu(
      config: customConfig,
      items: [
        SmartContextMenuItem.simple(
          title: 'Enabled',
          leading: const Text('A'),
          trailing: const Text('4'),
        ),
        SmartContextMenuItem.simple(
          title: 'Destructive',
          isDestructive: true,
          trailing: const Text('9'),
        ),
      ],
    );
    await tester.openMenu();

    for (final text in ['A', '4']) {
      final style = tester.paintedStyleOf(text);
      expect(style.fontFamily, 'Custom');
      expect(style.fontSize, 13);
      expect(style.color, isSameColorAs(customStyle.titleStyle.color!));
    }
    expect(
      tester.paintedStyleOf('9').color,
      isSameColorAs(customStyle.destructiveColor),
    );
  });

  testWidgets('text in trailing keeps its own style', (tester) async {
    const color = Color(0xFF0000FF);
    await tester.pumpMenu(
      config: customConfig,
      items: [
        SmartContextMenuItem.simple(
          title: 'Enabled',
          trailing: const Text('4', style: TextStyle(color: color)),
        ),
      ],
    );
    await tester.openMenu();

    final style = tester.paintedStyleOf('4');
    expect(style.color, isSameColorAs(color));
    expect(style.fontSize, 13);
  });
}
