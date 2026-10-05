import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider, Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  const customStyle = SmartContextMenuStyle(
    textStyle: TextStyle(
      fontFamily: 'Custom',
      fontSize: 13,
      color: Color(0xFF00FF00),
    ),
    secondaryTextColor: Color(0xFF000002),
    destructiveColor: Color(0xFF000003),
    disabledItemColor: Color(0xFF000004),
    dividerColor: Color(0xFF000005),
  );
  const customConfig = SmartContextMenuConfig(style: customStyle);

  final items = [
    SmartContextMenuItem.simple(title: 'Enabled', hasDivider: true),
    SmartContextMenuItem.simple(title: 'Disabled', isDisabled: true),
    SmartContextMenuItem.simple(title: 'Destructive', isDestructive: true),
  ];

  TextStyle titleStyleOf(WidgetTester tester, String title) =>
      tester.widget<Text>(find.text(title).first).style!;

  Color? backgroundOf(WidgetTester tester, String title) {
    final container = tester.widget<AnimatedContainer>(
      find
          .ancestor(
            of: find.text(title),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    return (container.decoration as BoxDecoration?)?.color;
  }

  Color dividerColorOf(WidgetTester tester) =>
      tester.widget<Divider>(find.byType(Divider)).color!;

  Color light(CupertinoDynamicColor color) => color.color;

  group('without style', () {
    testWidgets('uses the default text style and colors', (tester) async {
      await tester.pumpMenu(items: items, brightness: Brightness.light);
      await tester.openMenu();

      final enabled = titleStyleOf(tester, 'Enabled');
      expect(enabled.fontSize, SmartContextMenuDefaults.textStyle.fontSize);
      expect(
        enabled.color,
        isSameColorAs(light(SmartContextMenuDefaults.textColor)),
      );
      expect(
        titleStyleOf(tester, 'Disabled').color,
        isSameColorAs(light(SmartContextMenuDefaults.secondaryTextColor)),
      );
      expect(
        titleStyleOf(tester, 'Destructive').color,
        isSameColorAs(light(SmartContextMenuDefaults.destructiveColor)),
      );
      expect(
        backgroundOf(tester, 'Disabled'),
        isSameColorAs(light(SmartContextMenuDefaults.disabledItemColor)),
      );
      expect(
        dividerColorOf(tester),
        isSameColorAs(light(SmartContextMenuDefaults.dividerColor)),
      );
    });
  });

  group('with style', () {
    testWidgets('applies the text style', (tester) async {
      await tester.pumpMenu(items: items, config: customConfig);
      await tester.openMenu();

      final enabled = titleStyleOf(tester, 'Enabled');
      expect(enabled.fontFamily, 'Custom');
      expect(enabled.fontSize, 13);
      expect(enabled.color, isSameColorAs(customStyle.textStyle.color!));
    });

    testWidgets('uses the default text color if the style has none', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: items,
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(textStyle: TextStyle(fontSize: 13)),
        ),
        brightness: Brightness.light,
      );
      await tester.openMenu();

      final enabled = titleStyleOf(tester, 'Enabled');
      expect(enabled.fontSize, 13);
      expect(
        enabled.color,
        isSameColorAs(light(SmartContextMenuDefaults.textColor)),
      );
    });

    testWidgets('applies the item colors', (tester) async {
      await tester.pumpMenu(items: items, config: customConfig);
      await tester.openMenu();

      expect(
        titleStyleOf(tester, 'Disabled').color,
        isSameColorAs(customStyle.secondaryTextColor),
      );
      expect(
        titleStyleOf(tester, 'Destructive').color,
        isSameColorAs(customStyle.destructiveColor),
      );
      expect(
        backgroundOf(tester, 'Disabled'),
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
        items: items,
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(textStyle: TextStyle(color: textColor)),
        ),
        brightness: Brightness.dark,
      );
      await tester.openMenu();

      expect(
        titleStyleOf(tester, 'Enabled').color,
        isSameColorAs(textColor.darkColor),
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

      final style = titleStyleOf(tester, 'Styled');
      expect(style.fontSize, 21);
      expect(style.fontFamily, isNull);
      expect(style.color, isSameColorAs(const Color(0xFF0000FF)));
    });

    testWidgets('styles the back item', (tester) async {
      await tester.pumpMenu(
        config: customConfig,
        items: [
          SmartContextMenuItem.submenu(
            title: 'More',
            children: [SmartContextMenuItem.simple(title: 'Child')],
          ),
        ],
      );
      await tester.openMenu();
      await tester.tap(find.text('More'));
      await tester.settleMenu();

      final back = titleStyleOf(tester, customConfig.labels.back);
      expect(back.fontFamily, 'Custom');
      expect(back.fontSize, 13);
      expect(back.fontWeight, FontWeight.w600);
      expect(back.color, isSameColorAs(customStyle.textStyle.color!));
    });
  });

  group('icons', () {
    final submenu = [
      SmartContextMenuItem.submenu(
        title: 'More',
        children: [SmartContextMenuItem.simple(title: 'Child')],
      ),
    ];

    testWidgets('uses the default icons', (tester) async {
      await tester.pumpMenu(items: submenu);
      await tester.openMenu();
      expect(find.byIcon(SmartContextMenuDefaults.submenuIcon), findsOneWidget);

      await tester.tap(find.text('More'));
      await tester.settleMenu();
      expect(find.byIcon(SmartContextMenuDefaults.backIcon), findsWidgets);
    });

    testWidgets('applies the submenu and back icons', (tester) async {
      await tester.pumpMenu(
        items: submenu,
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(
            submenuIcon: Icons.arrow_forward_ios,
            backIcon: Icons.arrow_back_ios_new,
          ),
        ),
      );
      await tester.openMenu();
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      expect(find.byIcon(SmartContextMenuDefaults.submenuIcon), findsNothing);

      await tester.tap(find.text('More'));
      await tester.settleMenu();
      expect(find.byIcon(Icons.arrow_back_ios_new), findsWidgets);
      expect(find.byIcon(SmartContextMenuDefaults.backIcon), findsNothing);
    });
  });

  group('loader', () {
    Future<EdgeInsetsGeometry> loaderPaddingOf(
      WidgetTester tester, {
      SmartContextMenuConfig config = const SmartContextMenuConfig(),
    }) async {
      final completer = Completer<List<SmartContextMenuItem>>();
      await tester.pumpMenu(
        config: config,
        items: [
          SmartContextMenuItem.asyncSubmenu(
            title: 'More',
            asyncChildren: () => completer.future,
          ),
        ],
      );
      await tester.openMenu();
      await tester.tap(find.text('More'));
      await tester.settleMenu();

      return tester
          .widget<Padding>(
            find
                .ancestor(
                  of: find.byType(CupertinoActivityIndicator),
                  matching: find.byType(Padding),
                )
                .first,
          )
          .padding;
    }

    testWidgets('uses the default vertical padding', (tester) async {
      expect(
        await loaderPaddingOf(tester),
        const EdgeInsets.symmetric(
          vertical: SmartContextMenuDefaults.loaderVerticalPadding,
        ),
      );
    });

    testWidgets('applies the vertical padding', (tester) async {
      expect(
        await loaderPaddingOf(
          tester,
          config: const SmartContextMenuConfig(
            style: SmartContextMenuStyle(loaderVerticalPadding: 16),
          ),
        ),
        const EdgeInsets.symmetric(vertical: 16),
      );
    });
  });
}
