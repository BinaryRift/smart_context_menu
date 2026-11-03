import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/keys/service_item_key.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_back_item.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  Finder backItem(Key key) => find.ancestor(
    of: find.byKey(key, skipOffstage: false),
    matching: find.byType(SmartContextMenuBackItem, skipOffstage: false),
  );

  Finder visibleBack() => backItem(ServiceItemKey.back);

  Finder backgroundWith(Decoration decoration, {bool sameInstance = false}) =>
      find.descendant(
        of: visibleBack(),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              (sameInstance
                  ? identical(widget.decoration, decoration)
                  : widget.decoration == decoration),
        ),
      );

  Future<void> openSubmenu(
    WidgetTester tester,
    SmartContextMenuStyle style,
  ) async {
    await tester.pumpMenu(
      config: SmartContextMenuConfig(style: style),
      items: submenuItems(),
    );
    await tester.openSubmenu();
  }

  testWidgets('uses menuColor and backButtonBorderRadius by default', (
    tester,
  ) async {
    const color = Color(0xFF123456);
    const radius = BorderRadius.only(topLeft: Radius.circular(18));
    await openSubmenu(
      tester,
      const SmartContextMenuStyle(
        menuColor: color,
        backButtonBorderRadius: radius,
      ),
    );

    expect(
      backgroundWith(const BoxDecoration(color: color, borderRadius: radius)),
      findsOneWidget,
    );
    final clip = tester.widget<ClipRRect>(
      find.descendant(of: visibleBack(), matching: find.byType(ClipRRect)),
    );
    expect(clip.borderRadius, radius);
  });

  testWidgets('uses the custom decoration for paint and blur clip', (
    tester,
  ) async {
    const decoration = BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF123456), Color(0xFF654321)]),
      borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
    );
    await openSubmenu(
      tester,
      const SmartContextMenuStyle(
        menuColor: Color(0xFFABCDEF),
        backButtonBorderRadius: BorderRadius.zero,
        backButtonDecoration: decoration,
      ),
    );

    final background = tester.widget<DecoratedBox>(
      backgroundWith(decoration, sameInstance: true),
    );
    expect(background.decoration, same(decoration));

    final clipFinder = find.descendant(
      of: visibleBack(),
      matching: find.byType(ClipPath),
    );
    final clip = tester.widget<ClipPath>(clipFinder);
    final path = clip.clipper!.getClip(tester.getSize(clipFinder));
    expect(path.contains(const Offset(1, 1)), isFalse);
    expect(path.contains(const Offset(24, 24)), isTrue);
    expect(
      find.descendant(of: clipFinder, matching: find.byType(BackdropFilter)),
      findsOneWidget,
    );
  });

  testWidgets('keeps blur under a transparent custom decoration', (
    tester,
  ) async {
    const decoration = BoxDecoration(color: Color(0x00000000));
    await openSubmenu(
      tester,
      const SmartContextMenuStyle(backButtonDecoration: decoration),
    );

    final background = tester.widget<DecoratedBox>(
      backgroundWith(decoration, sameInstance: true),
    );
    expect(background.decoration, same(decoration));
    expect(
      find.descendant(of: visibleBack(), matching: find.byType(BackdropFilter)),
      findsOneWidget,
    );
  });

  testWidgets('a decoration border does not change the reserved height', (
    tester,
  ) async {
    await openSubmenu(
      tester,
      SmartContextMenuStyle(
        backButtonDecoration: BoxDecoration(border: Border.all(width: 6)),
      ),
    );

    expect(
      tester.getSize(visibleBack()).height,
      tester.getSize(backItem(ServiceItemKey.backPlaceholder)).height,
    );
  });
}
