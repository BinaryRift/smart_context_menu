import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider, Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  Color dividerColorOf(WidgetTester tester) =>
      tester.widget<Divider>(find.byType(Divider)).color!;

  testWidgets('uses the default colors', (tester) async {
    await tester.pumpMenu(
      items: appearanceItems(),
      brightness: Brightness.light,
    );
    await tester.openMenu();

    expect(
      tester.titleStyleOf('Enabled').color,
      isSameColorAs(light(SmartContextMenuDefaults.textColor)),
    );
    expect(
      tester.titleStyleOf('Disabled').color,
      isSameColorAs(light(SmartContextMenuDefaults.secondaryTextColor)),
    );
    expect(
      tester.titleStyleOf('Destructive').color,
      isSameColorAs(light(SmartContextMenuDefaults.destructiveColor)),
    );
    expect(
      tester.backgroundOf('Disabled'),
      isSameColorAs(light(SmartContextMenuDefaults.disabledItemColor)),
    );
    expect(
      dividerColorOf(tester),
      isSameColorAs(light(SmartContextMenuDefaults.dividerColor)),
    );
  });

  testWidgets('applies the style colors', (tester) async {
    await tester.pumpMenu(items: appearanceItems(), config: customConfig);
    await tester.openMenu();

    expect(
      tester.titleStyleOf('Disabled').color,
      isSameColorAs(customStyle.secondaryTextColor),
    );
    expect(
      tester.titleStyleOf('Destructive').color,
      isSameColorAs(customStyle.destructiveColor),
    );
    expect(
      tester.backgroundOf('Disabled'),
      isSameColorAs(customStyle.disabledItemColor),
    );
    expect(dividerColorOf(tester), isSameColorAs(customStyle.dividerColor));
  });

  testWidgets('resolves dynamic colors for the theme', (tester) async {
    const textColor = CupertinoDynamicColor.withBrightness(
      color: Color(0xFF000001),
      darkColor: Color(0xFF000002),
    );
    await tester.pumpMenu(
      items: appearanceItems(),
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(textStyle: TextStyle(color: textColor)),
      ),
      brightness: Brightness.dark,
    );
    await tester.openMenu();

    expect(
      tester.titleStyleOf('Enabled').color,
      isSameColorAs(textColor.darkColor),
    );
  });

  group('press highlight', () {
    final textColor = SmartContextMenuDefaults.textColor;

    testWidgets('is lighter in the light theme', (tester) async {
      await tester.pumpMenu(
        items: appearanceItems(),
        brightness: Brightness.light,
      );
      await tester.openMenu();
      final gesture = await tester.pressAt(find.text('Enabled'));

      expect(
        tester.backgroundOf('Enabled'),
        isSameColorAs(textColor.color.withValues(alpha: 0.06)),
      );
      await tester.releaseOutside(gesture);
    });

    testWidgets('is stronger in the dark theme', (tester) async {
      await tester.pumpMenu(
        items: appearanceItems(),
        brightness: Brightness.dark,
      );
      await tester.openMenu();
      final gesture = await tester.pressAt(find.text('Enabled'));

      expect(
        tester.backgroundOf('Enabled'),
        isSameColorAs(textColor.darkColor.withValues(alpha: 0.1)),
      );
      await tester.releaseOutside(gesture);
    });

    testWidgets('is stronger on the back item in the light theme', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: submenuItems(),
        brightness: Brightness.light,
      );
      await tester.openSubmenu();
      final gesture = await tester.pressAt(find.text('Child'));
      // The placeholder of the back item comes first.
      final back = find.text(const SmartContextMenuLabels().back).last;
      await gesture.moveTo(tester.getCenter(back));
      await tester.pump();

      expect(
        tester.backgroundAt(back),
        isSameColorAs(textColor.color.withValues(alpha: 0.16)),
      );
      await tester.releaseOutside(gesture);
    });
  });

  group('tint color', () {
    const tintColor = Color(0xFF00AA00);

    testWidgets('tints the title, icons and background', (tester) async {
      await tester.pumpMenu(
        config: customConfig,
        items: [
          SmartContextMenuItem.simple(
            title: 'Tinted',
            tintColor: tintColor,
            leading: const Icon(Icons.check),
          ),
          SmartContextMenuItem.simple(
            title: 'Destructive',
            isDestructive: true,
          ),
        ],
      );
      await tester.openMenu();

      expect(tester.titleStyleOf('Tinted').color, isSameColorAs(tintColor));
      expect(tester.iconColorOf(Icons.check), isSameColorAs(tintColor));
      expect(
        tester.backgroundOf('Tinted'),
        isSameColorAs(tintColor.withValues(alpha: 0.12)),
      );
      expect(
        tester.backgroundOf('Destructive'),
        isSameColorAs(customStyle.destructiveColor.withValues(alpha: 0.12)),
      );
    });

    testWidgets('takes precedence over destructive and title colors', (
      tester,
    ) async {
      await tester.pumpMenu(
        config: customConfig,
        items: [
          SmartContextMenuItem.simple(
            title: 'Tinted',
            tintColor: tintColor,
            isDestructive: true,
            titleStyle: const TextStyle(color: Color(0xFF0000FF)),
          ),
        ],
      );
      await tester.openMenu();

      expect(tester.titleStyleOf('Tinted').color, isSameColorAs(tintColor));
      expect(
        tester.backgroundOf('Tinted'),
        isSameColorAs(tintColor.withValues(alpha: 0.12)),
      );
    });

    testWidgets('dims a disabled item', (tester) async {
      await tester.pumpMenu(
        config: customConfig,
        items: [
          SmartContextMenuItem.simple(
            title: 'Tinted',
            tintColor: tintColor,
            isDisabled: true,
          ),
        ],
      );
      await tester.openMenu();

      expect(
        tester.titleStyleOf('Tinted').color,
        isSameColorAs(tintColor.withValues(alpha: 0.5)),
      );
      expect(
        tester.backgroundOf('Tinted'),
        isSameColorAs(tintColor.withValues(alpha: 0.08)),
      );
    });

    testWidgets('resolves a dynamic color for the theme', (tester) async {
      const dynamicTint = CupertinoDynamicColor.withBrightness(
        color: Color(0xFF000001),
        darkColor: Color(0xFF000002),
      );
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.simple(title: 'Tinted', tintColor: dynamicTint),
        ],
        brightness: Brightness.dark,
      );
      await tester.openMenu();

      expect(
        tester.titleStyleOf('Tinted').color,
        isSameColorAs(dynamicTint.darkColor),
      );
    });
  });
}
