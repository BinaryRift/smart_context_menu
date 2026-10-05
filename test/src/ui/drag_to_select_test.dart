import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  testWidgets('releasing over another item triggers that item', (tester) async {
    final taps = <String>[];

    await tester.pumpMenu(
      items: [
        for (final title in ['First', 'Second'])
          SmartContextMenuItem.simple(
            title: title,
            closeOnTap: false,
            onTap: () => taps.add(title),
          ),
      ],
    );
    await tester.openMenu();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('First')),
    );
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('Second')));
    await tester.pump();
    await gesture.up();
    await tester.settleMenu();

    expect(taps, ['Second']);
  });

  testWidgets('releasing outside the items triggers nothing', (tester) async {
    var taps = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(
          title: 'First',
          closeOnTap: false,
          onTap: () => taps++,
        ),
      ],
    );
    await tester.openMenu();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('First')),
    );
    await tester.pump();
    await gesture.moveTo(const Offset(1, 1));
    await tester.pump();
    await gesture.up();
    await tester.settleMenu();

    expect(taps, 0);
  });

  testWidgets('an interactive child of an item handles the tap itself', (
    tester,
  ) async {
    var itemTaps = 0;
    var buttonTaps = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(
          closeOnTap: false,
          onTap: () => itemTaps++,
          customBuilder: (context, state) => Row(
            children: [
              const Expanded(child: Text('Item')),
              CupertinoButton(
                onPressed: () => buttonTaps++,
                child: const Text('Button'),
              ),
            ],
          ),
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('Button'));
    await tester.settleMenu();
    expect(buttonTaps, 1);
    expect(itemTaps, 0);

    await tester.tap(find.text('Item'));
    await tester.settleMenu();
    expect(itemTaps, 1);
  });
}
