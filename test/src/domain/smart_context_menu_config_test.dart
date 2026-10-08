import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('has the documented defaults', () {
    const config = SmartContextMenuConfig();

    expect(config.labels, same(const SmartContextMenuLabels()));
    expect(config.enableHaptics, isTrue);
    expect(config.enableSwipeBack, isTrue);
    expect(config.barrierDismissible, isTrue);
    expect(config.activationMode, SmartContextMenuActivationMode.longPress);
    expect(config.menuWidth, 280);
    expect(config.menuHeightFactor, 0.6);
    expect(config.screenPadding, SmartContextMenuDefaults.screenPadding);
    expect(config.menuGap, SmartContextMenuDefaults.menuGap);
    expect(config.moveBackDown, isFalse);
    expect(config.style, same(const SmartContextMenuStyle()));
  });

  group('copyWith', () {
    const original = SmartContextMenuConfig(
      labels: SmartContextMenuLabels(back: 'Back 1'),
      enableHaptics: false,
      enableSwipeBack: false,
      barrierDismissible: false,
      activationMode: SmartContextMenuActivationMode.manual,
      menuWidth: 200,
      menuHeightFactor: 0.5,
      screenPadding: EdgeInsets.all(8),
      menuGap: 4,
      moveBackDown: true,
      style: SmartContextMenuStyle(menuBlur: SmartContextMenuBlur.small),
    );

    final fields = <String, Object? Function(SmartContextMenuConfig)>{
      'labels': (c) => c.labels,
      'enableHaptics': (c) => c.enableHaptics,
      'enableSwipeBack': (c) => c.enableSwipeBack,
      'barrierDismissible': (c) => c.barrierDismissible,
      'activationMode': (c) => c.activationMode,
      'menuWidth': (c) => c.menuWidth,
      'menuHeightFactor': (c) => c.menuHeightFactor,
      'screenPadding': (c) => c.screenPadding,
      'menuGap': (c) => c.menuGap,
      'moveBackDown': (c) => c.moveBackDown,
      'style': (c) => c.style,
    };

    const labels = SmartContextMenuLabels(back: 'Back 2');
    const style = SmartContextMenuStyle(menuBlur: SmartContextMenuBlur.strong);
    final changes = <String, (Object, SmartContextMenuConfig Function())>{
      'labels': (labels, () => original.copyWith(labels: labels)),
      'enableHaptics': (true, () => original.copyWith(enableHaptics: true)),
      'enableSwipeBack': (true, () => original.copyWith(enableSwipeBack: true)),
      'barrierDismissible': (
        true,
        () => original.copyWith(barrierDismissible: true),
      ),
      'activationMode': (
        SmartContextMenuActivationMode.longPress,
        () => original.copyWith(
          activationMode: SmartContextMenuActivationMode.longPress,
        ),
      ),
      'menuWidth': (300.0, () => original.copyWith(menuWidth: 300)),
      'menuHeightFactor': (0.8, () => original.copyWith(menuHeightFactor: 0.8)),
      'screenPadding': (
        const EdgeInsets.all(24),
        () => original.copyWith(screenPadding: const EdgeInsets.all(24)),
      ),
      'menuGap': (20.0, () => original.copyWith(menuGap: 20)),
      'moveBackDown': (false, () => original.copyWith(moveBackDown: false)),
      'style': (style, () => original.copyWith(style: style)),
    };

    test('covers every field', () {
      expect(changes.keys, unorderedEquals(fields.keys));
    });

    test('without arguments keeps every field', () {
      final copy = original.copyWith();
      for (final MapEntry(key: name, value: get) in fields.entries) {
        expect(get(copy), get(original), reason: name);
      }
    });

    for (final MapEntry(key: changed, value: (value, copyWith))
        in changes.entries) {
      test('changes only $changed', () {
        final copy = copyWith();
        for (final MapEntry(key: name, value: get) in fields.entries) {
          expect(
            get(copy),
            name == changed ? value : get(original),
            reason: name,
          );
        }
      });
    }
  });
}
