import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/theme/smart_context_menu_item_colors.dart';

const _transparent = Color(0x00000000);
const _foreground = SmartContextMenuDefaults.foregroundColor;
const _destructive = SmartContextMenuDefaults.destructiveColor;

extension on WidgetTester {
  Future<SmartContextMenuItemColors> resolveColors(
    SmartContextMenuItem item, {
    SmartContextMenuStyle style = const SmartContextMenuStyle(),
    bool isPressed = false,
    bool isBack = false,
    Brightness brightness = Brightness.light,
  }) async {
    late SmartContextMenuItemColors colors;
    await pumpWidget(
      CupertinoTheme(
        data: CupertinoThemeData(brightness: brightness),
        child: Builder(
          builder: (context) {
            colors = SmartContextMenuItemColors.resolve(
              context,
              item: item,
              style: style,
              isPressed: isPressed,
              isBack: isBack,
            );
            return const SizedBox();
          },
        ),
      ),
    );
    return colors;
  }
}

void main() {
  group('an enabled item', () {
    testWidgets('takes the title color and has no background', (tester) async {
      final colors = await tester.resolveColors(SmartContextMenuItem.simple());

      expect(colors.foreground, isSameColorAs(_foreground.color));
      expect(colors.overlay, isSameColorAs(_transparent));
    });

    testWidgets('takes the color of its title style', (tester) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(
          titleStyle: const TextStyle(color: Color(0xFF000001)),
        ),
      );

      expect(colors.foreground, isSameColorAs(const Color(0xFF000001)));
    });

    testWidgets('is highlighted with the title color while pressed', (
      tester,
    ) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(),
        isPressed: true,
      );

      expect(
        colors.overlay,
        isSameColorAs(
          _foreground.color.withValues(
            alpha: SmartContextMenuDefaults.highlightOpacity,
          ),
        ),
      );
    });

    testWidgets('uses the highlight color of the style', (tester) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(),
        style: const SmartContextMenuStyle(highlightColor: Color(0xFF000002)),
        isPressed: true,
      );

      expect(colors.overlay, isSameColorAs(const Color(0xFF000002)));
    });

    testWidgets('uses the dark variants in the dark theme', (tester) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(),
        isPressed: true,
        brightness: Brightness.dark,
      );

      expect(colors.foreground, isSameColorAs(_foreground.darkColor));
      expect(
        colors.overlay,
        isSameColorAs(
          _foreground.darkColor.withValues(
            alpha: SmartContextMenuDefaults.darkHighlightOpacity,
          ),
        ),
      );
    });
  });

  group('the back item', () {
    testWidgets('has a stronger highlight in the light theme', (tester) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(),
        isPressed: true,
        isBack: true,
      );

      expect(
        colors.overlay,
        isSameColorAs(
          _foreground.color.withValues(
            alpha: SmartContextMenuDefaults.backHighlightOpacity,
          ),
        ),
      );
    });

    testWidgets('has the usual highlight in the dark theme', (tester) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(),
        isPressed: true,
        isBack: true,
        brightness: Brightness.dark,
      );

      expect(
        colors.overlay,
        isSameColorAs(
          _foreground.darkColor.withValues(
            alpha: SmartContextMenuDefaults.darkHighlightOpacity,
          ),
        ),
      );
    });
  });

  group('a disabled item', () {
    testWidgets('is dimmed and has no background', (tester) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(isDisabled: true),
        isPressed: true,
      );

      expect(
        colors.foreground,
        isSameColorAs(SmartContextMenuDefaults.disabledForegroundColor.color),
      );
      expect(colors.overlay, isSameColorAs(_transparent));
    });

    testWidgets('uses the disabled background of the style', (tester) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(isDisabled: true),
        style: const SmartContextMenuStyle(
          disabledBackgroundColor: Color(0xFF000003),
        ),
      );

      expect(colors.overlay, isSameColorAs(const Color(0xFF000003)));
    });
  });

  group('a destructive item', () {
    testWidgets('is tinted with the destructive color', (tester) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(isDestructive: true),
      );

      expect(colors.foreground, isSameColorAs(_destructive.color));
      expect(
        colors.overlay,
        isSameColorAs(
          _destructive.color.withValues(
            alpha: SmartContextMenuDefaults.tintOpacity,
          ),
        ),
      );
    });

    testWidgets('has a stronger tint while pressed', (tester) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(isDestructive: true),
        isPressed: true,
      );

      expect(
        colors.overlay,
        isSameColorAs(
          _destructive.color.withValues(
            alpha: SmartContextMenuDefaults.tintPressedOpacity,
          ),
        ),
      );
    });

    testWidgets('uses the dark tint opacities in the dark theme', (
      tester,
    ) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(isDestructive: true),
        isPressed: true,
        brightness: Brightness.dark,
      );

      expect(
        colors.overlay,
        isSameColorAs(
          _destructive.darkColor.withValues(
            alpha: SmartContextMenuDefaults.darkTintPressedOpacity,
          ),
        ),
      );
    });
  });

  group('a tinted item', () {
    testWidgets('takes its tint over the destructive color', (tester) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(
          isDestructive: true,
          tintColor: const Color(0xFF0000FF),
        ),
      );

      expect(colors.foreground, isSameColorAs(const Color(0xFF0000FF)));
    });

    testWidgets('keeps a dimmed tint when disabled', (tester) async {
      final colors = await tester.resolveColors(
        SmartContextMenuItem.simple(
          isDisabled: true,
          tintColor: const Color(0xFF0000FF),
        ),
      );

      expect(
        colors.foreground,
        isSameColorAs(
          const Color(0xFF0000FF).withValues(
            alpha: SmartContextMenuDefaults.tintDisabledForegroundOpacity,
          ),
        ),
      );
      expect(colors.overlay, isSameColorAs(_transparent));
    });
  });
}
