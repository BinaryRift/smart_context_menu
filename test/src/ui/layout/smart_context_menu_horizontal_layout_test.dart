import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/layout/smart_context_menu_horizontal_layout.dart';

/// A layout for a 100-wide widget at [left] on a 400-wide screen.
SmartContextMenuHorizontalLayout _layout(double left) {
  return SmartContextMenuHorizontalLayout(
    anchorRect: Rect.fromLTWH(left, 0, 100, 40),
    screenWidth: 400,
    screenPadding: const EdgeInsets.all(16),
  );
}

void main() {
  test('centers under a widget in the middle of the screen', () {
    final layout = _layout(150);

    expect(layout.alignment, Alignment.topCenter);
    expect(layout.padding, EdgeInsets.zero);
  });

  test('centers under a widget a few pixels off the middle', () {
    expect(_layout(155).alignment, Alignment.topCenter);
  });

  test('lines up with the left edge of a widget on the left', () {
    final layout = _layout(30);

    expect(layout.alignment, Alignment.topLeft);
    expect(layout.padding, const EdgeInsets.only(left: 30));
  });

  test('lines up with the right edge of a widget on the right', () {
    final layout = _layout(270);

    expect(layout.alignment, Alignment.topRight);
    expect(layout.padding, const EdgeInsets.only(right: 30));
  });

  test('keeps the screen padding for a widget at the screen edge', () {
    expect(_layout(4).padding, const EdgeInsets.only(left: 16));
    expect(_layout(296).padding, const EdgeInsets.only(right: 16));
  });
}
