import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/state/smart_context_menu_level_entry.dart';

const _right = Offset(0.5, 0);
const _left = Offset(-0.5, 0);

void main() {
  // Starting an animation reads the accessibility features of the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late AnimationController controller;
  late SmartContextMenuLevelEntry entry;

  setUp(() {
    controller = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 300),
    );
    entry = SmartContextMenuLevelEntry(
      child: const SizedBox(),
      controller: controller,
      enterFrom: _right,
    );
  });
  tearDown(() => controller.dispose());

  test('comes in from enterFrom', () {
    expect(entry.offset, _right);

    controller.value = 0.5;
    expect(entry.offset.dx, inExclusiveRange(0, 0.5));

    controller.value = 1;
    expect(entry.offset, Offset.zero);
  });

  test('leaves towards the given side', () {
    controller.value = 1;
    entry.leave(_left);
    expect(entry.offset, Offset.zero);

    controller.value = 0.5;
    expect(entry.offset.dx, inExclusiveRange(-0.5, 0));

    controller.value = 0;
    expect(entry.offset, _left);
  });

  test('leaves from where it is when interrupted', () {
    controller.value = 0.5;
    final interrupted = entry.offset;

    entry.leave(_left);
    expect(entry.offset, interrupted);

    controller.value = 0.25;
    expect(entry.offset.dx, inExclusiveRange(-0.5, interrupted.dx));

    controller.value = 0;
    expect(entry.offset, _left);
  });

  test('position follows the offset', () {
    final values = <Offset>[];
    entry.position.addListener(() => values.add(entry.position.value));

    controller.value = 1;
    entry.leave(_left);
    controller.value = 0;

    expect(values.last, _left);
  });
}
