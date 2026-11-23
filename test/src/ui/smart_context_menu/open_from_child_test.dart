// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/menu_tester.dart';

void main() {
  /// A "More" button that opens the menu around it via [SmartContextMenu.of].
  Widget moreButton(String text) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => SmartContextMenu.of(context).open(),
        child: Text(text),
      ),
    );
  }

  Widget buildApp({
    SmartContextMenuActivationMode mode =
        SmartContextMenuActivationMode.longPress,
    SmartContextMenuController? controller,
    ValueSetter<SmartContextMenuController>? onController,
  }) {
    return CupertinoApp(
      home: Center(
        child: SmartContextMenu(
          config: SmartContextMenuConfig(activationMode: mode),
          controller: controller,
          items: [SmartContextMenuItem.simple(title: 'Copy')],
          child: Builder(
            builder: (context) {
              onController?.call(SmartContextMenu.of(context));
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [const Text(menuTargetText), moreButton('More')],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> tapMore(WidgetTester tester, [String text = 'More']) async {
    await tester.tap(find.text(text));
    await tester.settleMenu();
  }

  testWidgets('a button in the child opens the menu', (tester) async {
    late SmartContextMenuController menu;
    await tester.pumpWidget(buildApp(onController: (c) => menu = c));

    await tapMore(tester);
    expect(find.text('Copy'), findsOneWidget);
    expect(menu.isOpen, isTrue);

    menu.close();
    await tester.settleMenu();
    expect(find.text('Copy'), findsNothing);
    expect(menu.isOpen, isFalse);
  });

  testWidgets('a button in the child opens a manual menu without a '
      'controller', (tester) async {
    late SmartContextMenuController menu;
    await tester.pumpWidget(
      buildApp(
        mode: SmartContextMenuActivationMode.manual,
        onController: (c) => menu = c,
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.openMenu();
    expect(find.text('Copy'), findsNothing);

    await tapMore(tester);
    expect(find.text('Copy'), findsOneWidget);

    menu.close();
    await tester.settleMenu();
  });

  testWidgets('the own controller follows a long press', (tester) async {
    late SmartContextMenuController menu;
    await tester.pumpWidget(buildApp(onController: (c) => menu = c));

    await tester.openMenu();
    expect(menu.isOpen, isTrue);

    menu.close();
    await tester.settleMenu();
    expect(menu.isOpen, isFalse);
  });

  testWidgets('of returns the passed controller', (tester) async {
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);
    late SmartContextMenuController menu;
    await tester.pumpWidget(
      buildApp(controller: controller, onController: (c) => menu = c),
    );
    expect(menu, same(controller));

    await tapMore(tester);
    expect(controller.isOpen, isTrue);

    controller.close();
    await tester.settleMenu();
    expect(controller.isOpen, isFalse);
  });

  testWidgets('of follows a change of the passed controller', (tester) async {
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);
    late SmartContextMenuController menu;

    await tester.pumpWidget(buildApp(onController: (c) => menu = c));
    final own = menu;
    expect(own, isNot(same(controller)));

    await tester.pumpWidget(
      buildApp(controller: controller, onController: (c) => menu = c),
    );
    expect(menu, same(controller));

    await tester.pumpWidget(buildApp(onController: (c) => menu = c));
    expect(menu, same(own));
    expect(controller.isOpen, isFalse);

    await tapMore(tester);
    expect(own.isOpen, isTrue);
    expect(controller.isOpen, isFalse);

    own.close();
    await tester.settleMenu();
  });

  testWidgets('of finds the nearest of nested menus', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: SmartContextMenu(
            items: [SmartContextMenuItem.simple(title: 'Outer item')],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                moreButton('Outer more'),
                SmartContextMenu(
                  items: [SmartContextMenuItem.simple(title: 'Inner item')],
                  child: moreButton('Inner more'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tapMore(tester, 'Inner more');
    expect(find.text('Inner item'), findsOneWidget);
    expect(find.text('Outer item'), findsNothing);

    await tester.tapAt(const Offset(10, 10));
    await tester.settleMenu();
    expect(find.text('Inner item'), findsNothing);

    await tapMore(tester, 'Outer more');
    expect(find.text('Outer item'), findsOneWidget);
    expect(find.text('Inner item'), findsNothing);

    await tester.tapAt(const Offset(10, 10));
    await tester.settleMenu();
  });

  testWidgets('maybeOf is null and of fails outside a menu', (tester) async {
    late BuildContext outside;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          outside = context;
          return const SizedBox.shrink();
        },
      ),
    );

    expect(SmartContextMenu.maybeOf(outside), isNull);
    expect(() => SmartContextMenu.of(outside), throwsAssertionError);
  });
}
