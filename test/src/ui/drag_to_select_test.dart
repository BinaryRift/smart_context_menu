import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/appearance_tester.dart';
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

    await tester.dragTo(find.text('First'), find.text('Second'));

    expect(taps, ['Second']);
  });

  testWidgets('highlights the item under the finger', (tester) async {
    const transparent = Color(0x00000000);
    await tester.pumpMenu(
      items: [
        for (final title in ['First', 'Second'])
          SmartContextMenuItem.simple(title: title, closeOnTap: false),
      ],
    );
    await tester.openMenu();

    final gesture = await tester.pressAt(find.text('First'));
    expect(tester.backgroundOf('First'), isNot(isSameColorAs(transparent)));
    expect(tester.backgroundOf('Second'), isSameColorAs(transparent));

    await gesture.moveTo(tester.getCenter(find.text('Second')));
    await tester.pump();
    expect(tester.backgroundOf('First'), isSameColorAs(transparent));
    expect(tester.backgroundOf('Second'), isNot(isSameColorAs(transparent)));

    await tester.releaseOutside(gesture);
  });

  testWidgets('releasing over a disabled item triggers nothing', (
    tester,
  ) async {
    final taps = <String>[];
    await tester.pumpMenu(
      items: [
        for (final (title, isDisabled) in [('First', false), ('Second', true)])
          SmartContextMenuItem.simple(
            title: title,
            isDisabled: isDisabled,
            closeOnTap: false,
            onTap: () => taps.add(title),
          ),
      ],
    );
    await tester.openMenu();

    await tester.dragTo(find.text('First'), find.text('Second'));

    expect(taps, isEmpty);
  });

  testWidgets('canceling the pointer triggers nothing', (tester) async {
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
    await gesture.moveBy(const Offset(2, 0));
    await tester.pump();
    await gesture.cancel();
    await tester.settleMenu();

    expect(taps, 0);
    expect(find.text('First'), findsOneWidget);
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

  group('scrolling the items', () {
    final taps = <String>[];
    final items = [
      for (var i = 1; i <= 40; i++)
        SmartContextMenuItem.simple(
          title: 'Item $i',
          closeOnTap: false,
          onTap: () => taps.add('Item $i'),
        ),
    ];

    setUp(taps.clear);

    Future<void> scrollAndRelease(WidgetTester tester) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Item 5')),
      );
      await tester.pump();
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(0, -15));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.settleMenu();
    }

    testWidgets('releasing after a scroll triggers nothing', (tester) async {
      await tester.pumpMenu(items: items);
      await tester.openMenu();

      await scrollAndRelease(tester);

      expect(taps, isEmpty);
    });

    testWidgets('releasing after a scroll in a submenu triggers nothing', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: [SmartContextMenuItem.submenu(title: 'More', children: items)],
      );
      await tester.openMenu();
      await tester.tap(find.text('More'));
      await tester.settleMenu();

      await scrollAndRelease(tester);

      expect(taps, isEmpty);
    });

    testWidgets('the next tap after a scroll triggers the item', (
      tester,
    ) async {
      await tester.pumpMenu(items: items);
      await tester.openMenu();
      await scrollAndRelease(tester);

      await tester.tap(find.text('Item 10'));
      await tester.settleMenu();

      expect(taps, ['Item 10']);
    });
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
