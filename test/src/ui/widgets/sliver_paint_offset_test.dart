import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/widgets/sliver_paint_offset.dart';

const _box = ValueKey('box');

Widget _scrollView({required Offset offset, ValueChanged<Offset>? onTapDown}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: CustomScrollView(
      slivers: [
        SliverPaintOffset(
          offset: offset,
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => onTapDown?.call(details.localPosition),
                child: const SizedBox(key: _box, width: 50, height: 50),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ),
  );
}

void main() {
  testWidgets('paints the sliver moved by the offset', (tester) async {
    await tester.pumpWidget(_scrollView(offset: const Offset(20, 10)));

    expect(tester.getTopLeft(find.byKey(_box)), const Offset(20, 10));
  });

  testWidgets('does not change the layout', (tester) async {
    await tester.pumpWidget(_scrollView(offset: const Offset(20, 10)));
    final moved = tester.getTopLeft(find.byType(SizedBox).last);

    await tester.pumpWidget(_scrollView(offset: Offset.zero));

    expect(tester.getTopLeft(find.byType(SizedBox).last), moved);
  });

  testWidgets('hit tests the sliver where it is painted', (tester) async {
    final taps = <Offset>[];
    await tester.pumpWidget(
      _scrollView(offset: const Offset(20, 10), onTapDown: taps.add),
    );

    // Inside the moved box, outside the box at its layout place.
    await tester.tapAt(const Offset(60, 45));
    // At its layout place, outside the moved box.
    await tester.tapAt(const Offset(5, 5));

    expect(taps, [const Offset(40, 35)]);
  });
}
