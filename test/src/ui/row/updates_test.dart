import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';
import '../../../helpers/row_tester.dart';

const _highlight = Color(0x33000001);
const _config = SmartContextMenuConfig(
  style: SmartContextMenuStyle(highlightColor: _highlight),
);
const _shortTitle = 'Pin';
const _longTitle = 'Pin to the top of the list';

/// A row with a listenable cell whose title gets long, so the row grows,
/// when [isLong] is true, and an item below the row.
List<SmartContextMenuItem> _items(ValueNotifier<bool> isLong) => [
  SmartContextMenuItem.row(
    children: [
      rowCell('Copy'),
      SmartContextMenuItem.listenable(
        listenable: isLong,
        builder: () => rowCell(isLong.value ? _longTitle : _shortTitle),
      ),
      rowCell('Share'),
    ],
  ),
  rowCell('Reply'),
];

Future<TestGesture> _mouseAt(WidgetTester tester, Offset position) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(position);
  await tester.pump();
  return mouse;
}

void main() {
  late ValueNotifier<bool> isLong;

  setUp(() => isLong = ValueNotifier(false));
  tearDown(() => isLong.dispose());

  testWidgets('a rebuilt cell keeps the hover of a stationary cursor', (
    tester,
  ) async {
    await tester.pumpMenu(config: _config, items: _items(isLong));
    await tester.openMenu();
    await _mouseAt(tester, tester.getCenter(find.text(_shortTitle)));
    expect(tester.backgroundOf(_shortTitle), isSameColorAs(_highlight));

    isLong.value = true;
    await tester.pumpAndSettle();

    expect(tester.backgroundOf(_longTitle), isSameColorAs(_highlight));
    expect(tester.backgroundOf('Copy'), isSameColorAs(transparent));
    expect(tester.backgroundOf('Share'), isSameColorAs(transparent));
  });

  testWidgets('the hover follows a stationary cursor when the row grows', (
    tester,
  ) async {
    await tester.pumpMenu(config: _config, items: _items(isLong));
    await tester.openMenu();
    // At the top of Reply under Share, so the grown row comes under the
    // cursor.
    final cursor = Offset(
      tester.cellRectOf('Share').center.dx,
      tester.cellRectOf('Reply').top + 2,
    );
    await _mouseAt(tester, cursor);
    expect(tester.backgroundOf('Reply'), isSameColorAs(_highlight));

    isLong.value = true;
    await tester.pumpAndSettle();

    final share = tester.cellRectOf('Share');
    expect(share.contains(cursor), isTrue);
    expect(tester.backgroundOf('Share'), isSameColorAs(_highlight));
    expect(tester.backgroundOf('Reply'), isSameColorAs(transparent));
  });

  testWidgets('the menu stays in place when a row grows', (tester) async {
    await tester.pumpMenu(items: _items(isLong));
    await tester.openMenu();
    final row = tester.getRect(rowLayouts);
    final reply = tester.cellRectOf('Reply');

    isLong.value = true;
    await tester.pumpAndSettle();

    final grownRow = tester.getRect(rowLayouts);
    expect(grownRow.top, row.top);
    expect(grownRow.height, greaterThan(row.height));
    expect(
      tester.cellRectOf('Reply').top - reply.top,
      grownRow.height - row.height,
    );
  });
}
