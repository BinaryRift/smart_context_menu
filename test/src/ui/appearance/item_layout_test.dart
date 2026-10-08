import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  EdgeInsetsGeometry? paddingOf(WidgetTester tester, Finder finder) => tester
      .widget<AnimatedContainer>(
        find
            .ancestor(of: finder, matching: find.byType(AnimatedContainer))
            .first,
      )
      .padding;

  double gapAfter(WidgetTester tester, IconData icon, String title) =>
      tester.getTopLeft(find.text(title)).dx -
      tester.getTopRight(find.byIcon(icon)).dx;

  testWidgets('uses the default padding and gap', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(
          title: 'Edit',
          leading: const Icon(Icons.edit),
        ),
      ],
    );
    await tester.openMenu();

    expect(
      paddingOf(tester, find.text('Edit')),
      SmartContextMenuDefaults.itemPadding,
    );
    expect(
      gapAfter(tester, Icons.edit, 'Edit'),
      SmartContextMenuDefaults.itemChildrenGap,
    );
  });

  testWidgets('applies the style padding and gap', (tester) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          itemPadding: EdgeInsets.all(4),
          itemChildrenGap: 6,
        ),
      ),
      items: [
        SmartContextMenuItem.simple(
          title: 'Edit',
          leading: const Icon(Icons.edit),
        ),
      ],
    );
    await tester.openMenu();

    expect(paddingOf(tester, find.text('Edit')), const EdgeInsets.all(4));
    expect(gapAfter(tester, Icons.edit, 'Edit'), 6);
  });

  testWidgets('item padding and gap take precedence', (tester) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          itemPadding: EdgeInsets.all(4),
          itemChildrenGap: 6,
        ),
      ),
      items: [
        SmartContextMenuItem.simple(
          title: 'Edit',
          leading: const Icon(Icons.edit),
          padding: const EdgeInsets.all(2),
          childrenGap: 3,
        ),
      ],
    );
    await tester.openMenu();

    expect(paddingOf(tester, find.text('Edit')), const EdgeInsets.all(2));
    expect(gapAfter(tester, Icons.edit, 'Edit'), 3);
  });

  testWidgets('applies the style padding to the back item', (tester) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(itemPadding: EdgeInsets.all(4)),
      ),
      items: submenuItems(),
    );
    await tester.openSubmenu();

    final back = find.text(const SmartContextMenuLabels().back).last;
    expect(paddingOf(tester, back), const EdgeInsets.all(4));
  });
}
