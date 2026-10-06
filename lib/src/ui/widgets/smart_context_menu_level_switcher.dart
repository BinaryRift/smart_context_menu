import 'package:flutter/widgets.dart';

import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_slides.dart';
import '../state/smart_context_menu_level_entry.dart';
import 'smart_context_menu_level_transition.dart';

/// Switches menu levels: a submenu slides in from the right and pushes
/// the current level to the left; going back, the parent slides in from
/// the left and pushes the submenu to the right.
///
/// Give each level its own key, so a new level is animated in.
final class SmartContextMenuLevelSwitcher extends StatefulWidget {
  /// Whether [child] is a submenu opened from the current level.
  final bool isForward;
  final Widget child;

  const SmartContextMenuLevelSwitcher({
    super.key,
    required this.isForward,
    required this.child,
  });

  @override
  State<SmartContextMenuLevelSwitcher> createState() =>
      _SmartContextMenuLevelSwitcherState();
}

final class _SmartContextMenuLevelSwitcherState
    extends State<SmartContextMenuLevelSwitcher>
    with TickerProviderStateMixin {
  late SmartContextMenuLevelEntry _current;
  final List<SmartContextMenuLevelEntry> _leaving = [];

  @override
  void initState() {
    super.initState();
    _current = _createEntry(
      widget.child,
      enterFrom: MotionSlide.rightHalf.offset,
    )..controller.value = 1;
  }

  @override
  void didUpdateWidget(SmartContextMenuLevelSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (Widget.canUpdate(_current.child, widget.child)) {
      _current.child = widget.child;
      return;
    }

    _leave(
      _current,
      to: widget.isForward
          ? MotionSlide.leftHalf.offset
          : MotionSlide.rightHalf.offset,
    );
    _current = _createEntry(
      widget.child,
      enterFrom: widget.isForward
          ? MotionSlide.rightHalf.offset
          : MotionSlide.leftHalf.offset,
    )..controller.forward();
  }

  @override
  void dispose() {
    _current.controller.dispose();
    for (final entry in _leaving) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  SmartContextMenuLevelEntry _createEntry(
    Widget child, {
    required Offset enterFrom,
  }) {
    return SmartContextMenuLevelEntry(
      child: child,
      controller: AnimationController(
        vsync: this,
        duration: MotionDurations.standard,
      ),
      enterFrom: enterFrom,
    );
  }

  void _leave(SmartContextMenuLevelEntry entry, {required Offset to}) {
    _leaving.add(entry);
    entry.leave(to).whenCompleteOrCancel(() {
      if (!mounted || entry.controller.value != 0) return;
      setState(() => _leaving.remove(entry));
      entry.controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: widget.isForward
          ? Alignment.centerRight
          : Alignment.centerLeft,
      children: [
        for (final entry in _leaving) _buildEntry(entry),
        _buildEntry(_current),
      ],
    );
  }

  Widget _buildEntry(SmartContextMenuLevelEntry entry) {
    return SmartContextMenuLevelTransition(
      key: ObjectKey(entry),
      animation: entry.controller,
      position: entry.position,
      child: entry.child,
    );
  }
}
