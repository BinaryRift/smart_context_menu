import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/extensions/render_object_ext.dart';
import 'package:smart_context_menu/src/ui/keys/service_item_key.dart';

const _rootKey = Key('root');
const _first = ValueKey('first');
const _second = ValueKey('second');

Widget _item(Key key, {Widget? child}) {
  return MetaData(
    metaData: key,
    behavior: HitTestBehavior.opaque,
    child: child ?? const SizedBox(width: double.infinity, height: 50),
  );
}

extension on WidgetTester {
  Future<void> pumpTree(Widget child) {
    return pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(key: _rootKey, width: 200, height: 300, child: child),
        ),
      ),
    );
  }

  Key? findAt(Offset position) =>
      renderObject(find.byKey(_rootKey)).findMenuItemKeyAt(position);
}

void main() {
  testWidgets('finds the item under the pointer', (tester) async {
    await tester.pumpTree(Column(children: [_item(_first), _item(_second)]));

    expect(tester.findAt(const Offset(100, 25)), _first);
    expect(tester.findAt(const Offset(100, 75)), _second);
  });

  testWidgets('returns null over empty space and outside the root', (
    tester,
  ) async {
    await tester.pumpTree(Column(children: [_item(_first)]));

    expect(tester.findAt(const Offset(100, 200)), isNull);
    expect(tester.findAt(const Offset(300, 25)), isNull);
  });

  testWidgets('finds items inside a scroll view', (tester) async {
    await tester.pumpTree(ListView(children: [_item(_first), _item(_second)]));

    expect(tester.findAt(const Offset(100, 75)), _second);
  });

  testWidgets('is not blocked by interactive ancestors', (tester) async {
    await tester.pumpTree(
      Listener(
        child: GestureDetector(
          onTap: () {},
          child: Column(children: [_item(_first)]),
        ),
      ),
    );

    expect(tester.findAt(const Offset(100, 25)), _first);
  });

  testWidgets('returns null over an interactive child of the item', (
    tester,
  ) async {
    await tester.pumpTree(
      Column(
        children: [
          _item(
            _first,
            child: Row(
              children: [
                const SizedBox(width: 100, height: 50),
                GestureDetector(
                  onTap: () {},
                  child: const SizedBox(width: 50, height: 50),
                ),
                Listener(child: const SizedBox(width: 50, height: 50)),
              ],
            ),
          ),
        ],
      ),
    );

    expect(tester.findAt(const Offset(50, 25)), _first);
    expect(tester.findAt(const Offset(125, 25)), isNull);
    expect(tester.findAt(const Offset(175, 25)), isNull);
  });

  testWidgets('prefers the pinned back item over its invisible copy', (
    tester,
  ) async {
    await tester.pumpTree(
      Stack(
        children: [
          ListView(
            children: [
              Visibility.maintain(
                visible: false,
                child: IgnorePointer(
                  child: _item(ServiceItemKey.backPlaceholder),
                ),
              ),
              _item(_first),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _item(ServiceItemKey.back),
          ),
        ],
      ),
    );

    expect(tester.findAt(const Offset(100, 25)), ServiceItemKey.back);
    expect(tester.findAt(const Offset(100, 75)), _first);
  });

  testWidgets('finds the invisible back copy when nothing covers it', (
    tester,
  ) async {
    await tester.pumpTree(
      Column(
        children: [
          Visibility.maintain(
            visible: false,
            child: IgnorePointer(child: _item(ServiceItemKey.backPlaceholder)),
          ),
        ],
      ),
    );

    expect(
      tester.findAt(const Offset(100, 25)),
      ServiceItemKey.backPlaceholder,
    );
  });
}
