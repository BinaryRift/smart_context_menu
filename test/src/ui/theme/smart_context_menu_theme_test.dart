import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  const outer = SmartContextMenuConfig(menuWidth: 200);
  const inner = SmartContextMenuConfig(menuWidth: 300);

  Future<void> pumpReader(
    WidgetTester tester,
    Widget Function(Widget reader) wrap,
    void Function(BuildContext context) read,
  ) {
    return tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) {
            read(context);
            return const SizedBox();
          },
        ),
      ),
    );
  }

  testWidgets('of returns the default config without a theme', (tester) async {
    late SmartContextMenuConfig config;
    await pumpReader(
      tester,
      (reader) => reader,
      (context) => config = SmartContextMenuTheme.of(context),
    );

    expect(config, same(const SmartContextMenuConfig()));
  });

  testWidgets('maybeOf returns null without a theme', (tester) async {
    SmartContextMenuConfig? config = outer;
    await pumpReader(
      tester,
      (reader) => reader,
      (context) => config = SmartContextMenuTheme.maybeOf(context),
    );

    expect(config, isNull);
  });

  testWidgets('of returns the config of the theme', (tester) async {
    late SmartContextMenuConfig config;
    await pumpReader(
      tester,
      (reader) => SmartContextMenuTheme(config: outer, child: reader),
      (context) => config = SmartContextMenuTheme.of(context),
    );

    expect(config, same(outer));
  });

  testWidgets('the nearest theme wins', (tester) async {
    late SmartContextMenuConfig config;
    await pumpReader(
      tester,
      (reader) => SmartContextMenuTheme(
        config: outer,
        child: SmartContextMenuTheme(config: inner, child: reader),
      ),
      (context) => config = SmartContextMenuTheme.of(context),
    );

    expect(config, same(inner));
  });

  testWidgets('dependents rebuild when the config changes', (tester) async {
    final configs = <SmartContextMenuConfig>[];
    final reader = Builder(
      builder: (context) {
        configs.add(SmartContextMenuTheme.of(context));
        return const SizedBox();
      },
    );

    await tester.pumpWidget(
      SmartContextMenuTheme(config: outer, child: reader),
    );
    await tester.pumpWidget(
      SmartContextMenuTheme(config: inner, child: reader),
    );

    expect(configs, [same(outer), same(inner)]);
  });

  testWidgets('dependents do not rebuild for the same config', (tester) async {
    var builds = 0;
    final reader = Builder(
      builder: (context) {
        SmartContextMenuTheme.of(context);
        builds++;
        return const SizedBox();
      },
    );

    await tester.pumpWidget(
      SmartContextMenuTheme(config: outer, child: reader),
    );
    await tester.pumpWidget(
      SmartContextMenuTheme(config: outer, child: reader),
    );

    expect(builds, 1);
  });
}
