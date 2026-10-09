import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/core/ui/motion/tokens/motion_durations.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_level_switcher.dart';

/// A switcher showing [level]; pump it again with another level to switch.
Widget levelSwitcher(String level, {required bool isForward}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: SmartContextMenuLevelSwitcher(
      isForward: isForward,
      onSwipeBack: () {},
      child: Text(level, key: ValueKey(level)),
    ),
  );
}

/// Levels named by their depth; a swipe back goes one level up.
Widget swipeableSwitcher({int depth = 2, bool enableSwipeBack = true}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: StatefulBuilder(
      builder: (context, setState) => SmartContextMenuLevelSwitcher(
        isForward: false,
        enableSwipeBack: enableSwipeBack,
        onSwipeBack: () => setState(() => depth--),
        previous: depth > 1 ? _level(depth - 1) : null,
        child: _level(depth),
      ),
    ),
  );
}

Widget _level(int depth) => Text('Level $depth', key: ValueKey('Level $depth'));

/// Levels of different heights: level n is 100 * n high.
Widget sizedSwitcher({
  required int depth,
  bool isForward = true,
  double? height,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 300,
        child: StatefulBuilder(
          builder: (context, setState) => SmartContextMenuLevelSwitcher(
            isForward: isForward,
            enableSwipeBack: true,
            onSwipeBack: () => setState(() => depth--),
            previous: depth > 1 ? _sizedLevel(depth - 1) : null,
            child: _sizedLevel(depth, height: height),
          ),
        ),
      ),
    ),
  );
}

Widget _sizedLevel(int depth, {double? height}) => SizedBox(
  key: ValueKey('Level $depth'),
  height: height ?? 100.0 * depth,
  child: Text('Level $depth'),
);

extension LevelSwitcherTester on WidgetTester {
  double get switcherHeight =>
      getSize(find.byType(SmartContextMenuLevelSwitcher)).height;

  double slideOf(String level) {
    final slide = widget<SlideTransition>(
      find.ancestor(
        of: find.text(level),
        matching: find.byType(SlideTransition),
      ),
    );
    return slide.position.value.dx;
  }

  Future<void> pumpHalfway() => pump(MotionDurations.standard * 0.5);

  RenderClipRect clipOf(String level) => renderObject(
    find.ancestor(of: find.text(level), matching: find.byType(ClipRect)),
  );

  /// The width of [level] left visible by its clip, or null if it is not
  /// clipped.
  double? visibleWidthOf(String level) {
    final clip = clipOf(level);
    if (clip.clipBehavior == Clip.none) return null;
    return clip.clipper!.getClip(clip.size).width;
  }

  double opacityOf(String level) => widget<FadeTransition>(
    find.ancestor(of: find.text(level), matching: find.byType(FadeTransition)),
  ).opacity.value;

  /// Drags [level] right by [distance] slowly, so the release has no speed.
  Future<void> slowSwipe(String level, double distance) async {
    final gesture = await startGesture(getCenter(find.text(level)));
    const step = 50.0;
    for (var moved = 0.0; moved < distance; moved += step) {
      await gesture.moveBy(const Offset(step, 0));
      await pump(const Duration(milliseconds: 50));
    }
    await pump(const Duration(milliseconds: 300));
    await gesture.up();
    await pumpAndSettle();
  }
}
