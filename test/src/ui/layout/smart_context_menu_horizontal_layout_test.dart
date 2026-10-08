import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/layout/smart_context_menu_horizontal_layout.dart';

/// A layout for a 100-wide widget at [left] on a [screenWidth]-wide screen
/// and a [menuWidth]-wide menu.
SmartContextMenuHorizontalLayout _layout(
  double left, {
  double screenWidth = 400,
  double menuWidth = 200,
}) {
  return SmartContextMenuHorizontalLayout(
    anchorRect: Rect.fromLTWH(left, 0, 100, 40),
    screenWidth: screenWidth,
    screenPadding: const EdgeInsets.all(16),
    menuWidth: menuWidth,
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

  group('menuPadding', () {
    const screenPadding = EdgeInsets.symmetric(horizontal: 16);

    test('keeps the screen padding on both sides of a centered menu', () {
      expect(_layout(150).menuPadding, screenPadding);
    });

    test('lines up with the widget edge when the menu fits', () {
      expect(
        _layout(30).menuPadding,
        const EdgeInsets.only(left: 30, right: 16),
      );
      expect(
        _layout(270).menuPadding,
        const EdgeInsets.only(left: 16, right: 30),
      );
    });

    test('moves a menu that does not fit towards the middle', () {
      // 400 - 16 - 280 = 104: the farthest the menu edge can be.
      final left = _layout(120, menuWidth: 280);
      final right = _layout(180, menuWidth: 280);

      expect(left.alignment, Alignment.topLeft);
      expect(left.padding, const EdgeInsets.only(left: 120));
      expect(left.menuPadding, const EdgeInsets.only(left: 104, right: 16));
      expect(right.alignment, Alignment.topRight);
      expect(right.padding, const EdgeInsets.only(right: 120));
      expect(right.menuPadding, const EdgeInsets.only(left: 16, right: 104));
    });

    test('keeps the screen padding on a screen narrower than the menu', () {
      expect(
        _layout(40, screenWidth: 300, menuWidth: 280).menuPadding,
        screenPadding,
      );
      expect(
        _layout(160, screenWidth: 300, menuWidth: 280).menuPadding,
        screenPadding,
      );
    });
  });
}
