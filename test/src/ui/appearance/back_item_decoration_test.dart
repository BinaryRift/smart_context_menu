// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/controllers/smart_context_menu_overlay_controller.dart';
import 'package:smart_context_menu/src/domain/smart_context_menu_level.dart';
import 'package:smart_context_menu/src/ui/keys/service_item_key.dart';
import 'package:smart_context_menu/src/ui/state/smart_context_menu_hover_controller.dart';
import 'package:smart_context_menu/src/ui/view/smart_context_menu_level_view.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_back_item.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_divider.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';
import '../../../helpers/overlay_controller_tester.dart';

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
    SmartContextMenuStyle style, {
    Brightness? brightness,
  }) async {
    await tester.pumpMenu(
      config: SmartContextMenuConfig(style: style),
      items: submenuItems(),
      brightness: brightness,
    );
    await tester.openSubmenu();
  }

  testWidgets('uses the Standard panel color and the Back radius by default', (
    tester,
  ) async {
    const color = Color(0xFF123456);
    const radius = BorderRadius.only(topLeft: Radius.circular(18));
    await openSubmenu(
      tester,
      const SmartContextMenuStyle(
        standardStyle: SmartContextMenuStandardStyle(color: color),
        backButtonStyle: SmartContextMenuBackButtonStyle(borderRadius: radius),
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

  testWidgets('uses the resolved background color on Standard', (tester) async {
    const color = CupertinoDynamicColor.withBrightness(
      color: Color(0x60123456),
      darkColor: Color(0x80654321),
    );
    const radius = BorderRadius.only(topLeft: Radius.circular(18));
    await openSubmenu(
      tester,
      const SmartContextMenuStyle(
        surface: SmartContextMenuSurface.standard,
        backButtonStyle: SmartContextMenuBackButtonStyle(
          backgroundColor: color,
          borderRadius: radius,
        ),
      ),
      brightness: Brightness.dark,
    );

    final decorations = find.descendant(
      of: visibleBack(),
      matching: find.byType(DecoratedBox),
    );
    final fill = tester.widget<DecoratedBox>(decorations.first);
    final background = fill.decoration as BoxDecoration;
    expect(background.color, isSameColorAs(color.darkColor));
    expect(background.borderRadius, radius);
    expect(
      find.descendant(of: visibleBack(), matching: find.byType(BackdropFilter)),
      findsOneWidget,
    );
  });

  testWidgets('gives the decoration priority for paint and blur clip', (
    tester,
  ) async {
    const decoration = BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF123456), Color(0xFF654321)]),
      borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
    );
    await openSubmenu(
      tester,
      const SmartContextMenuStyle(
        standardStyle: SmartContextMenuStandardStyle(color: Color(0xFFABCDEF)),
        backButtonStyle: SmartContextMenuBackButtonStyle(
          backgroundColor: Color(0xFFAABBCC),
          borderRadius: BorderRadius.zero,
          decoration: decoration,
        ),
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
      const SmartContextMenuStyle(
        backButtonStyle: SmartContextMenuBackButtonStyle(
          decoration: decoration,
        ),
      ),
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
        backButtonStyle: SmartContextMenuBackButtonStyle(
          decoration: BoxDecoration(border: Border.all(width: 6)),
        ),
      ),
    );

    expect(
      tester.getSize(visibleBack()).height,
      tester.getSize(backItem(ServiceItemKey.backPlaceholder)).height,
    );
  });

  testWidgets('keeps the glass rim and animates blur with a custom fill', (
    tester,
  ) async {
    const color = Color(0x552387BA);
    final controller = SmartContextMenuOverlayController(
      navigator: FakeMenuNavigator(),
      initialItems: [],
      enableHaptics: false,
    );
    addTearDown(controller.dispose);
    final hoverController = SmartContextMenuHoverController();
    addTearDown(hoverController.dispose);
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: SizedBox(
            width: 250,
            height: 190,
            child: SmartContextMenuLevelView(
              level: SmartMenuLevel(
                parentId: 'submenu',
                items: [
                  for (var i = 1; i <= 10; i++)
                    SmartContextMenuItem.simple(title: 'Item $i'),
                ],
              ),
              controller: controller,
              config: const SmartContextMenuConfig(
                style: SmartContextMenuStyle(
                  backButtonStyle: SmartContextMenuBackButtonStyle(
                    backgroundColor: color,
                  ),
                ),
              ),
              hoverController: hoverController,
              glassTint: const Color(0x92F7FAFF),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      backgroundWith(
        const BoxDecoration(color: color, borderRadius: BorderRadius.zero),
      ),
      findsOneWidget,
    );
    final divider = tester.widget<SmartContextMenuDivider>(
      find.descendant(
        of: visibleBack(),
        matching: find.byType(SmartContextMenuDivider),
      ),
    );
    expect(divider.color, isNotNull);

    final back = find.byKey(ServiceItemKey.back);
    final backElement = tester.element(back);
    final pinnedBounds = tester.getRect(back);
    final blur = find.descendant(
      of: visibleBack(),
      matching: find.byType(BackdropFilter),
    );
    final innerClip = find.byWidgetPredicate(
      (widget) => widget is ClipRRect && widget.clipper != null,
    );
    final filterClip = find.ancestor(of: blur, matching: innerClip);
    final clipSize = tester.getSize(filterClip);
    final clip = tester
        .widget<ClipRRect>(filterClip)
        .clipper!
        .getClip(clipSize);
    expect(clip.left, 2);
    expect(clip.top, 2);
    expect(clip.right, clipSize.width - 2);
    expect(clip.tlRadius, const Radius.circular(14));
    expect(clip.trRadius, const Radius.circular(14));
    expect(find.ancestor(of: back, matching: innerClip), findsNothing);

    final listClip = find.ancestor(
      of: find.byType(ListView),
      matching: find.byType(ClipPath),
    );
    final listPath = tester
        .widget<ClipPath>(listClip)
        .clipper!
        .getClip(tester.getSize(listClip));
    expect(listPath.contains(const Offset(125, 1)), isFalse);
    expect(listPath.contains(const Offset(125, 10)), isTrue);
    expect(listPath.contains(const Offset(1, 22)), isFalse);
    expect(listPath.contains(Offset(1, pinnedBounds.height + 1)), isTrue);

    final scrollPosition = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    BackdropFilter backdrop() => tester.widget<BackdropFilter>(blur);

    final clearFilter = backdrop().filter;
    expect(backdrop().enabled, isFalse);

    scrollPosition.jumpTo(100);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(backdrop().enabled, isTrue);
    final rampingInFilter = backdrop().filter;
    expect(rampingInFilter, isNot(clearFilter));
    expect(tester.element(back), same(backElement));
    expect(tester.getRect(back), pinnedBounds);

    await tester.pumpAndSettle();
    final fullFilter = backdrop().filter;
    expect(fullFilter, isNot(rampingInFilter));
    expect(backdrop().enabled, isTrue);

    scrollPosition.jumpTo(scrollPosition.minScrollExtent);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(backdrop().enabled, isTrue);
    expect(backdrop().filter, isNot(fullFilter));
    expect(backdrop().filter, isNot(clearFilter));
    expect(tester.element(back), same(backElement));
    expect(tester.getRect(back), pinnedBounds);

    await tester.pumpAndSettle();
    expect(backdrop().enabled, isFalse);
    expect(backdrop().filter, clearFilter);
  });
}
