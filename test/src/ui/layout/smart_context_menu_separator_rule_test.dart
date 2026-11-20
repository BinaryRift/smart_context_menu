import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/layout/smart_context_menu_separator_rule.dart';

/// Builds items from [pattern] and returns what is shown of them.
///
/// In [pattern], `-` is a band, a word in capitals is a title (a separator
/// with a child), `x` is an item that is not shown, and any other word is
/// an item.
String shown(String pattern) {
  final tokens = pattern.split(' ');
  final items = [
    for (final token in tokens)
      if (token == '-')
        SmartContextMenuItem.separator()
      else if (token == token.toUpperCase())
        SmartContextMenuItem.separator(child: Text(token))
      else
        SmartContextMenuItem.simple(title: token),
  ];
  bool isHidden(SmartContextMenuItem item) =>
      item is SmartContextMenuSimpleItem && item.title == 'x';
  return [
    for (var i = 0; i < items.length; i++)
      if (isHidden(items[i]))
        null
      else if (items[i] is! SmartContextMenuSeparatorItem ||
          SmartContextMenuSeparatorRule.showsAt(items, i, isHidden: isHidden))
        tokens[i],
  ].nonNulls.join(' ');
}

void main() {
  test('shows a band between items', () {
    expect(shown('a - b'), 'a - b');
  });

  test('hides bands at the start and the end', () {
    expect(shown('- a -'), 'a');
    expect(shown('- - a - -'), 'a');
  });

  test('shows a title at the start but not at the end', () {
    expect(shown('T a'), 'T a');
    expect(shown('a T'), 'a');
    expect(shown('T'), '');
  });

  test('shows the first of several bands', () {
    final items = [
      SmartContextMenuItem.simple(title: 'a'),
      SmartContextMenuItem.separator(),
      SmartContextMenuItem.separator(),
      SmartContextMenuItem.simple(title: 'b'),
    ];
    expect(SmartContextMenuSeparatorRule.showsAt(items, 1), isTrue);
    expect(SmartContextMenuSeparatorRule.showsAt(items, 2), isFalse);
  });

  test('shows only the last title of several separators', () {
    expect(shown('a - T b'), 'a T b');
    expect(shown('a T - b'), 'a T b');
    expect(shown('a T U b'), 'a U b');
    expect(shown('- T - U - a'), 'U a');
  });

  test('does not count items that are not shown', () {
    expect(shown('x - a'), 'a');
    expect(shown('a - x'), 'a');
    expect(shown('a - x - b'), 'a - b');
    expect(shown('a - x T b'), 'a T b');
    expect(shown('x T a'), 'T a');
  });
}
