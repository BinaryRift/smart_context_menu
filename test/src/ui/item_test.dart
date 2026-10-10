import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/appearance_tester.dart';
import '../../helpers/menu_tester.dart';

void main() {
  group('tap', () {
    testWidgets('runs onTap and closes the menu', (tester) async {
      var taps = 0;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.simple(title: 'Copy', onTap: () => taps++),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('Copy'));
      await tester.settleMenu();

      expect(taps, 1);
      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('keeps the menu open when closeOnTap is false', (tester) async {
      var taps = 0;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.simple(
            title: 'Copy',
            closeOnTap: false,
            onTap: () => taps++,
          ),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('Copy'));
      await tester.settleMenu();

      expect(taps, 1);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('does nothing on a disabled item', (tester) async {
      var taps = 0;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.simple(
            title: 'Copy',
            isDisabled: true,
            onTap: () => taps++,
          ),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('Copy'));
      await tester.settleMenu();

      expect(taps, 0);
      expect(find.text('Copy'), findsOneWidget);
    });
  });

  group('highlight', () {
    const highlightColor = Color(0x33000001);
    const transparent = Color(0x00000000);
    const config = SmartContextMenuConfig(
      style: SmartContextMenuStyle(highlightColor: highlightColor),
    );

    SmartContextMenuItem item(String title, VoidCallback onTap) =>
        SmartContextMenuItem.simple(
          title: title,
          closeOnTap: false,
          onTap: onTap,
        );

    testWidgets('stays a moment after a quick tap, which runs at once', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpMenu(
        items: [item('Copy', () => taps++)],
        config: config,
      );
      await tester.openMenu();

      // Down and up in the same frame, as a tap on a touchpad.
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Copy')),
      );
      await gesture.up();
      await tester.pump();

      expect(taps, 1);
      expect(tester.backgroundOf('Copy'), isSameColorAs(highlightColor));

      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.backgroundOf('Copy'), isSameColorAs(transparent));
    });

    testWidgets('moves to the next item at once while dragging', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: [item('Copy', () {}), item('Paste', () {})],
        config: config,
      );
      await tester.openMenu();

      final gesture = await tester.pressAt(find.text('Copy'));
      await gesture.moveTo(tester.getCenter(find.text('Paste')));
      await tester.pump();

      expect(tester.backgroundOf('Copy'), isSameColorAs(transparent));
      expect(tester.backgroundOf('Paste'), isSameColorAs(highlightColor));

      await tester.releaseOutside(gesture);
    });

    testWidgets('is cleared at once after a long press', (tester) async {
      await tester.pumpMenu(items: [item('Copy', () {})], config: config);
      await tester.openMenu();

      final gesture = await tester.pressAt(find.text('Copy'));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pump();

      expect(tester.backgroundOf('Copy'), isSameColorAs(transparent));
    });
  });

  group('customBuilder', () {
    final states = <String, SmartContextMenuItemState>{};

    SmartContextMenuItem item(
      String title, {
      bool isDisabled = false,
      bool isDestructive = false,
      bool closeOnTap = true,
    }) => SmartContextMenuItem.simple(
      isDisabled: isDisabled,
      isDestructive: isDestructive,
      closeOnTap: closeOnTap,
      customBuilder: (context, state) {
        states[title] = state;
        return Text(title);
      },
    );

    setUp(states.clear);

    testWidgets('gets the flags and colors of the item', (tester) async {
      await tester.pumpMenu(
        brightness: Brightness.light,
        items: [
          item('Enabled'),
          item('Disabled', isDisabled: true),
          item('Destructive', isDestructive: true),
        ],
      );
      await tester.openMenu();

      final enabled = states['Enabled']!;
      expect(enabled.isPressed, isFalse);
      expect(enabled.isDisabled, isFalse);
      expect(enabled.isDestructive, isFalse);
      expect(
        enabled.foregroundColor,
        isSameColorAs(light(SmartContextMenuDefaults.foregroundColor)),
      );

      final disabled = states['Disabled']!;
      expect(disabled.isDisabled, isTrue);
      expect(disabled.isDestructive, isFalse);
      expect(
        disabled.foregroundColor,
        isSameColorAs(light(SmartContextMenuDefaults.disabledForegroundColor)),
      );

      final destructive = states['Destructive']!;
      expect(destructive.isDisabled, isFalse);
      expect(destructive.isDestructive, isTrue);
      expect(
        destructive.foregroundColor,
        isSameColorAs(light(SmartContextMenuDefaults.destructiveColor)),
      );
    });

    testWidgets('is pressed while the finger is over the item', (tester) async {
      await tester.pumpMenu(items: [item('Copy')]);
      await tester.openMenu();

      final gesture = await tester.pressAt(find.text('Copy'));
      expect(states['Copy']!.isPressed, isTrue);

      await tester.releaseOutside(gesture);
      expect(states['Copy']!.isPressed, isFalse);
    });

    testWidgets('is never pressed on a disabled item', (tester) async {
      await tester.pumpMenu(items: [item('Copy', isDisabled: true)]);
      await tester.openMenu();

      final gesture = await tester.pressAt(find.text('Copy'));
      expect(states['Copy']!.isPressed, isFalse);

      await tester.releaseOutside(gesture);
    });

    testWidgets('is never pressed on an item without an action', (
      tester,
    ) async {
      // No onTap and closeOnTap off: a tap does nothing, for example on
      // a row of buttons that handle their own taps.
      await tester.pumpMenu(items: [item('Colors', closeOnTap: false)]);
      await tester.openMenu();

      final gesture = await tester.pressAt(find.text('Colors'));
      expect(states['Colors']!.isPressed, isFalse);
      expect(states['Colors']!.isDisabled, isFalse);

      await tester.releaseOutside(gesture);
    });
  });
}
