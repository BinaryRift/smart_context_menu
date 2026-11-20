import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_row_layout.dart';

const _rowWidth = 300.0;
const _row = ValueKey('row');

Widget _pumpable(
  List<Widget> children, {
  EdgeInsets padding = EdgeInsets.zero,
  double childrenGap = 0,
  TextDirection textDirection = TextDirection.ltr,
}) {
  // A column leaves the height free, as the scroll view of the menu does.
  return Directionality(
    textDirection: textDirection,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _rowWidth,
          child: SmartContextMenuRowLayout(
            key: _row,
            padding: padding,
            childrenGap: childrenGap,
            children: children,
          ),
        ),
      ],
    ),
  );
}

Widget _cell(String key, {int flex = 1, double height = 20}) {
  return SmartContextMenuRowCell(
    flex: flex,
    child: SizedBox(key: ValueKey(key), height: height),
  );
}

// Relative to the row.
Rect _rectOf(WidgetTester tester, String key) => tester
    .getRect(find.byKey(ValueKey(key)))
    .shift(-tester.getTopLeft(find.byKey(_row)));

RenderSmartContextMenuRow _renderOf(WidgetTester tester) =>
    tester.renderObject<RenderSmartContextMenuRow>(find.byKey(_row));

void main() {
  group('width', () {
    testWidgets('is divided between the cells by their flex', (tester) async {
      await tester.pumpWidget(
        _pumpable([_cell('a'), _cell('b', flex: 2), _cell('c')]),
      );

      expect(_rectOf(tester, 'a'), const Rect.fromLTWH(0, 0, 75, 20));
      expect(_rectOf(tester, 'b'), const Rect.fromLTWH(75, 0, 150, 20));
      expect(_rectOf(tester, 'c'), const Rect.fromLTWH(225, 0, 75, 20));
    });

    testWidgets('is left to the cells after the other children', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pumpable([
          _cell('a'),
          const SizedBox(key: ValueKey('separator'), width: 10),
          _cell('b'),
        ]),
      );

      expect(_rectOf(tester, 'a').width, 145);
      expect(_rectOf(tester, 'separator').left, 145);
      expect(_rectOf(tester, 'separator').width, 10);
      expect(_rectOf(tester, 'b').left, 155);
      expect(_rectOf(tester, 'b').width, 145);
    });

    testWidgets('leaves out the padding and the gaps', (tester) async {
      await tester.pumpWidget(
        _pumpable(
          [_cell('a'), _cell('b')],
          padding: const EdgeInsets.fromLTRB(10, 4, 20, 6),
          childrenGap: 10,
        ),
      );

      expect(_rectOf(tester, 'a'), const Rect.fromLTWH(10, 4, 130, 20));
      expect(_rectOf(tester, 'b'), const Rect.fromLTWH(150, 4, 130, 20));
      expect(tester.getSize(find.byKey(_row)), const Size(_rowWidth, 30));
    });

    testWidgets('of the row is the full width of its constraints', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pumpable([const SizedBox(key: ValueKey('a'), width: 10)]),
      );

      expect(tester.getSize(find.byKey(_row)).width, _rowWidth);
    });

    testWidgets('follows a new flex', (tester) async {
      await tester.pumpWidget(_pumpable([_cell('a'), _cell('b')]));
      await tester.pumpWidget(_pumpable([_cell('a', flex: 2), _cell('b')]));

      expect(_rectOf(tester, 'a').width, 200);
      expect(_rectOf(tester, 'b').width, 100);
    });
  });

  group('height', () {
    testWidgets('of the row is the height of the tallest child', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pumpable([_cell('a', height: 20), _cell('b', height: 40)]),
      );

      expect(tester.getSize(find.byKey(_row)).height, 40);
    });

    testWidgets('of the row is taken by every child', (tester) async {
      await tester.pumpWidget(
        _pumpable([
          _cell('a', height: 20),
          Container(
            key: const ValueKey('separator'),
            width: 8,
            color: const Color(0xFF000001),
          ),
          _cell('b', height: 40),
        ]),
      );

      expect(_rectOf(tester, 'a').height, 40);
      expect(_rectOf(tester, 'separator').height, 40);
      expect(_rectOf(tester, 'b').height, 40);
    });

    testWidgets('follows the content of a cell', (tester) async {
      final height = ValueNotifier(20.0);
      addTearDown(height.dispose);
      await tester.pumpWidget(
        _pumpable([
          _cell('a', height: 30),
          SmartContextMenuRowCell(
            flex: 1,
            child: ValueListenableBuilder(
              valueListenable: height,
              builder: (context, value, child) =>
                  SizedBox(key: const ValueKey('b'), height: value),
            ),
          ),
        ]),
      );
      expect(tester.getSize(find.byKey(_row)).height, 30);

      height.value = 50;
      await tester.pump();
      expect(tester.getSize(find.byKey(_row)).height, 50);
      expect(_rectOf(tester, 'a').height, 50);

      height.value = 10;
      await tester.pump();
      expect(tester.getSize(find.byKey(_row)).height, 30);
      expect(_rectOf(tester, 'b').height, 30);
    });
  });

  testWidgets('puts the first child on the right in RTL', (tester) async {
    await tester.pumpWidget(
      _pumpable(
        [
          _cell('a'),
          const SizedBox(key: ValueKey('separator'), width: 30),
          _cell('b', flex: 2),
        ],
        padding: const EdgeInsets.only(left: 4, right: 16),
        childrenGap: 5,
        textDirection: TextDirection.rtl,
      ),
    );

    // 300 - 20 of padding - 10 of gaps - 30 of the separator.
    expect(_rectOf(tester, 'a'), const Rect.fromLTWH(204, 0, 80, 20));
    expect(_rectOf(tester, 'separator'), const Rect.fromLTWH(169, 0, 30, 20));
    expect(_rectOf(tester, 'b'), const Rect.fromLTWH(4, 0, 160, 20));
  });

  testWidgets('clips each child to its bounds', (tester) async {
    await tester.pumpWidget(
      _pumpable([
        const SmartContextMenuRowCell(
          flex: 1,
          child: SizedBox(
            height: 20,
            child: OverflowBox(
              maxWidth: 400,
              child: SizedBox(width: 400, height: 20),
            ),
          ),
        ),
        _cell('b'),
      ]),
    );

    expect(
      find.byKey(_row),
      paints
        ..clipRect(rect: const Rect.fromLTWH(0, 0, 150, 20))
        ..clipRect(rect: const Rect.fromLTWH(150, 0, 150, 20)),
    );
  });

  testWidgets('is not hit between the children', (tester) async {
    var rowTaps = 0;
    final cellTaps = <String>[];
    Widget tappableCell(String key) => SmartContextMenuRowCell(
      flex: 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => cellTaps.add(key),
        child: const SizedBox(height: 20),
      ),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: () => rowTaps++,
            child: SizedBox(
              width: _rowWidth,
              child: SmartContextMenuRowLayout(
                padding: const EdgeInsets.all(10),
                childrenGap: 20,
                children: [tappableCell('a'), tappableCell('b')],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(150, 20));
    await tester.tapAt(const Offset(5, 20));
    expect(rowTaps, 0);
    expect(cellTaps, isEmpty);

    await tester.tapAt(const Offset(20, 20));
    await tester.tapAt(const Offset(280, 20));
    expect(cellTaps, ['a', 'b']);
  });

  group('without layout', () {
    final children = [
      _cell('a', height: 20),
      const SizedBox(width: 10, height: 50),
      _cell('b', flex: 2, height: 40),
    ];
    const padding = EdgeInsets.fromLTRB(1, 2, 3, 4);

    testWidgets('dry layout matches the layout', (tester) async {
      await tester.pumpWidget(
        _pumpable(children, padding: padding, childrenGap: 5),
      );
      final row = _renderOf(tester);

      expect(
        row.getDryLayout(const BoxConstraints(maxWidth: _rowWidth)),
        row.size,
      );
      expect(row.size, const Size(_rowWidth, 56));
    });

    testWidgets('intrinsic height is the tallest child and the padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pumpable(children, padding: padding, childrenGap: 5),
      );
      final row = _renderOf(tester);

      expect(row.getMinIntrinsicHeight(_rowWidth), 56);
      expect(row.getMaxIntrinsicHeight(_rowWidth), 56);
    });

    testWidgets('intrinsic width fits each cell by its flex', (tester) async {
      await tester.pumpWidget(
        _pumpable(
          [
            const SmartContextMenuRowCell(
              flex: 1,
              child: SizedBox(width: 30, height: 20),
            ),
            const SizedBox(width: 10, height: 20),
            const SmartContextMenuRowCell(
              flex: 2,
              child: SizedBox(width: 40, height: 20),
            ),
          ],
          padding: padding,
          childrenGap: 5,
        ),
      );
      final row = _renderOf(tester);

      // The first cell needs 30 per flex, so 3 flex take 90; then the
      // separator, two gaps and the padding.
      expect(row.getMaxIntrinsicWidth(double.infinity), 90 + 10 + 10 + 4);
      expect(row.getMinIntrinsicWidth(double.infinity), 90 + 10 + 10 + 4);
    });
  });
}
