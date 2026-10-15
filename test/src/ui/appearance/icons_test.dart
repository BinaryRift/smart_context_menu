import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  testWidgets('uses the default icons', (tester) async {
    await tester.pumpMenu(items: submenuItems());
    await tester.openMenu();
    expect(find.byIcon(SmartContextMenuDefaults.submenuIcon), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.byIcon(SmartContextMenuDefaults.backIcon), findsWidgets);
  });

  testWidgets('reverses the default navigation chevrons in RTL', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: submenuItems(),
      textDirection: TextDirection.rtl,
    );
    await tester.openMenu();
    expect(find.byIcon(CupertinoIcons.chevron_back), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.byIcon(CupertinoIcons.chevron_forward), findsWidgets);
  });

  testWidgets('applies the submenu and back icons', (tester) async {
    await tester.pumpMenu(
      items: submenuItems(),
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

  testWidgets('applies the error, retry and empty icons', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.error(title: 'Could not sync'),
        SmartContextMenuItem.empty(title: 'No drafts'),
        SmartContextMenuItem.async(
          asyncItem: () => Future.error(Exception('Failed')),
        ),
      ],
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          errorIcon: Icons.error,
          retryIcon: Icons.refresh,
          emptyIcon: Icons.inbox,
        ),
      ),
    );
    await tester.openMenu();

    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.inbox), findsOneWidget);
    expect(find.byIcon(SmartContextMenuDefaults.errorIcon), findsNothing);
    expect(find.byIcon(SmartContextMenuDefaults.retryIcon), findsNothing);
    expect(find.byIcon(SmartContextMenuDefaults.emptyIcon), findsNothing);
  });

  testWidgets('tints icons with the title color', (tester) async {
    await tester.pumpMenu(
      config: customConfig,
      items: [
        SmartContextMenuItem.simple(
          title: 'Enabled',
          leading: const Icon(Icons.edit),
          trailing: const Icon(Icons.star),
        ),
        SmartContextMenuItem.simple(
          title: 'Disabled',
          isDisabled: true,
          leading: const Icon(Icons.block),
        ),
        SmartContextMenuItem.simple(
          title: 'Destructive',
          isDestructive: true,
          leading: const Icon(Icons.delete),
        ),
        ...submenuItems(),
      ],
    );
    await tester.openMenu();

    final foregroundColor = customStyle.titleStyle.color!;
    expect(tester.iconColorOf(Icons.edit), isSameColorAs(foregroundColor));
    expect(tester.iconColorOf(Icons.star), isSameColorAs(foregroundColor));
    expect(
      tester.iconColorOf(Icons.block),
      isSameColorAs(customStyle.disabledForegroundColor),
    );
    expect(
      tester.iconColorOf(Icons.delete),
      isSameColorAs(customStyle.destructiveColor),
    );
    expect(
      tester.iconColorOf(SmartContextMenuDefaults.submenuIcon),
      isSameColorAs(foregroundColor),
    );
  });

  testWidgets('keeps the color of an icon', (tester) async {
    const iconColor = Color(0xFF0000FF);
    await tester.pumpMenu(
      config: customConfig,
      items: [
        SmartContextMenuItem.simple(
          title: 'Destructive',
          isDestructive: true,
          leading: const Icon(Icons.delete, color: iconColor),
        ),
      ],
    );
    await tester.openMenu();

    final icon = tester.widget<RichText>(
      find.descendant(
        of: find.byIcon(Icons.delete),
        matching: find.byType(RichText),
      ),
    );
    expect(icon.text.style!.color, isSameColorAs(iconColor));
  });
}
