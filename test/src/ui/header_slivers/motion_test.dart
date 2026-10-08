import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/header_slivers_tester.dart';

/// How far the header and the preview have moved from [header] and
/// [preview].
(Offset, Offset) _moved(WidgetTester tester, Offset header, Offset preview) {
  return (
    tester.getTopLeft(headerFinder) - header,
    tester.getTopLeft(previewFinder) - preview,
  );
}

void main() {
  testWidgets('the slivers move with the dragged preview', (tester) async {
    await tester.pumpWidget(headerMenu());
    await tester.openMenuForPointers();
    final header = tester.getTopLeft(headerFinder);
    final preview = tester.getTopLeft(previewFinder);

    final gesture = await tester.startGesture(tester.getCenter(previewFinder));
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    final (headerShift, previewShift) = _moved(tester, header, preview);
    expect(previewShift.dy, greaterThan(0));
    expect(headerShift, previewShift);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_moved(tester, header, preview), (Offset.zero, Offset.zero));
  });

  testWidgets('the slivers move with the stretched menu', (tester) async {
    await tester.pumpWidget(
      headerMenu(
        items: [
          SmartContextMenuItem.simple(
            title: 'Copy',
            closeOnTap: false,
            onTap: () {},
          ),
        ],
      ),
    );
    await tester.openMenuForPointers();
    final header = tester.getTopLeft(headerFinder);
    final preview = tester.getTopLeft(previewFinder);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Copy')),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(40, 0));
    await tester.pumpAndSettle();
    final (headerShift, previewShift) = _moved(tester, header, preview);
    expect(previewShift.dx, greaterThan(0));
    expect(headerShift, previewShift);

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
