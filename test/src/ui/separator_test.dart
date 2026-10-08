import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  Finder bandOf(Color color) => find.byWidgetPredicate(
    (widget) =>
        widget is ColoredBox && widget.color.toARGB32() == color.toARGB32(),
  );

  testWidgets('shows the default band', (tester) async {
    await tester.pumpMenu(
      brightness: Brightness.light,
      items: [
        SmartContextMenuItem.simple(title: 'Copy'),
        SmartContextMenuItem.separator(),
        SmartContextMenuItem.simple(title: 'Delete'),
      ],
    );
    await tester.openMenu();

    final band = bandOf(SmartContextMenuDefaults.separatorColor.color);
    expect(band, findsOneWidget);
    expect(
      tester.getSize(band).height,
      SmartContextMenuDefaults.separatorHeight,
    );
  });

  testWidgets('applies the style', (tester) async {
    const color = Color(0xFF000001);
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(separatorHeight: 3, separatorColor: color),
      ),
      items: [
        SmartContextMenuItem.simple(title: 'Copy'),
        SmartContextMenuItem.separator(),
      ],
    );
    await tester.openMenu();

    expect(tester.getSize(bandOf(color)).height, 3);
  });

  testWidgets('child replaces the band', (tester) async {
    await tester.pumpMenu(
      brightness: Brightness.light,
      items: [
        SmartContextMenuItem.simple(title: 'Copy'),
        SmartContextMenuItem.separator(child: const Text('Danger zone')),
      ],
    );
    await tester.openMenu();

    expect(find.text('Danger zone'), findsOneWidget);
    expect(bandOf(SmartContextMenuDefaults.separatorColor.color), findsNothing);
  });

  testWidgets('releasing over the separator triggers nothing', (tester) async {
    var taps = 0;
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'Copy', onTap: () => taps++),
        SmartContextMenuItem.separator(child: const Text('Section')),
      ],
    );
    await tester.openMenu();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Copy')),
    );
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('Section')));
    await tester.pump();
    await gesture.up();
    await tester.settleMenu();

    expect(taps, 0);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('tapping the separator does not close the menu', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'Copy'),
        SmartContextMenuItem.separator(child: const Text('Section')),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('Section'));
    await tester.settleMenu();

    expect(find.text('Copy'), findsOneWidget);
  });
}
