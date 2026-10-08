import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/layout/smart_context_menu_vertical_layout.dart';

const _screenHeight = 600.0;
const _safe = 16.0;
const _gap = 12.0;

/// A layout for a widget at [anchorTop] on a 600-tall screen with 16 kept
/// from both edges and a 12 menu gap.
SmartContextMenuVerticalLayout _layout({
  required double anchorTop,
  double previewHeight = 40,
  double headerExtent = 0,
  bool moveBackDown = false,
}) {
  return SmartContextMenuVerticalLayout(
      anchorTop: anchorTop,
      previewHeight: previewHeight,
      menuGap: _gap,
      moveBackDown: moveBackDown,
    )
    ..headerExtent = headerExtent
    ..setBounds(screenHeight: _screenHeight, topSafe: _safe, bottomSafe: _safe);
}

void main() {
  test('keeps the preview in place when the menu fits below it', () {
    final layout = _layout(anchorTop: 100);

    expect(layout.update(200), isFalse);
    expect(layout.previewTop, 100);
    expect(layout.topPadding, 100);
  });

  test('moves the preview up only as far as the menu needs', () {
    final layout = _layout(anchorTop: 400);
    layout.update(200);

    // 600 - 16 - 200 - 12 - 40.
    expect(layout.previewTop, 332);
  });

  test('keeps the preview in place when the header fits above it', () {
    final layout = _layout(anchorTop: 100, headerExtent: 50);
    layout.update(200);

    expect(layout.previewTop, 100);
    expect(layout.topPadding, 50);
  });

  test('moves the preview down when the header does not fit above it', () {
    final layout = _layout(anchorTop: 30);
    layout.update(200);
    expect(layout.previewTop, 30);

    layout.headerExtent = 50;
    layout.update(200);

    expect(layout.previewTop, _safe + 50);
    expect(layout.topPadding, _safe);
  });

  group('when the content does not fit', () {
    test('a tall header makes the content scroll', () {
      // 40 + 12 + 450 fit into 568 alone, but not with a 100 header.
      final layout = _layout(anchorTop: 100);
      expect(layout.isOverflowing(450), isFalse);

      layout.headerExtent = 100;

      expect(layout.isOverflowing(450), isTrue);
      expect(layout.update(450), isTrue);
      expect(layout.previewTop, _safe + 100);
    });

    test('a tall widget makes the content scroll without a header', () {
      final layout = _layout(anchorTop: 50, previewHeight: 520);

      expect(layout.isOverflowing(100), isTrue);
      expect(layout.update(100), isTrue);
      expect(layout.previewTop, _safe);
    });

    test('scrolls to the bottom only when the content grows', () {
      final layout = _layout(anchorTop: 50, previewHeight: 520);

      expect(layout.update(100), isTrue);
      expect(layout.update(100), isFalse);
      expect(layout.update(80), isFalse);
      expect(layout.update(120), isTrue);

      layout.headerExtent = 30;
      expect(layout.update(120), isTrue);
    });
  });

  group('when the menu gets shorter', () {
    test('keeps the preview where it is by default', () {
      final layout = _layout(anchorTop: 400);
      layout.update(200);
      layout.update(50);

      expect(layout.previewTop, 332);
    });

    test('with moveBackDown moves it back, but not below its place', () {
      final layout = _layout(anchorTop: 400, moveBackDown: true);
      layout.update(200);
      layout.update(150);
      expect(layout.previewTop, 382);

      layout.update(50);
      expect(layout.previewTop, 400);
    });

    test('with moveBackDown keeps it while the content scrolls', () {
      final layout = _layout(
        anchorTop: 300,
        previewHeight: 200,
        moveBackDown: true,
      );
      layout.update(500);
      final top = layout.previewTop;

      // Still taller than the 356 threshold.
      layout.update(400);

      expect(layout.previewTop, top);
    });
  });
}
