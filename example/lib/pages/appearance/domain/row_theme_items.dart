// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../core/ui/demo_notice.dart';
import '../ui/theme_styles.dart';
import 'appearance_items.dart';

const _clipboardColors = [
  CupertinoDynamicColor.withBrightness(
    color: Color(0xFFDC2858),
    darkColor: Color(0xFFFF718F),
  ),
  CupertinoDynamicColor.withBrightness(
    color: Color(0xFF1D5FE8),
    darkColor: Color(0xFF80AAFF),
  ),
  CupertinoDynamicColor.withBrightness(
    color: Color(0xFF008877),
    darkColor: Color(0xFF52DFC1),
  ),
];

/// Formatting and alignment stay visible while changing the selection.
List<SmartContextMenuItem> editingRowsItems(
  ValueNotifier<Set<String>> formatting,
  ValueNotifier<String> alignment,
) => [
  SmartContextMenuItem.row(
    size: SmartContextMenuRowSize.small,
    children: [
      for (final (index, action) in formattingActions.indexed)
        SmartContextMenuItem.listenable(
          listenable: formatting,
          builder: () {
            final selected = formatting.value.contains(action.title);
            return _editingCell(
              action,
              corners: _sectionCorners(index, formattingActions.length),
              selected: selected,
              onTap: () {
                final next = {...formatting.value};
                if (!next.remove(action.title)) next.add(action.title);
                formatting.value = next;
              },
              icon: (color) => _formatMark(action, color),
            );
          },
        ),
    ],
  ),
  SmartContextMenuItem.row(
    size: SmartContextMenuRowSize.small,
    children: [
      for (final (index, action) in alignmentActions.indexed)
        SmartContextMenuItem.listenable(
          listenable: alignment,
          builder: () => _editingCell(
            action,
            corners: _sectionCorners(index, alignmentActions.length),
            selected: alignment.value == action.title,
            onTap: () => alignment.value = action.title,
            icon: (color) => Icon(action.icon, color: color, size: 20),
          ),
        ),
    ],
  ),
  SmartContextMenuItem.row(
    children: [
      for (final (index, action) in clipboardActions.indexed)
        _editingCell(
          action,
          iconColor: _clipboardColors[index],
          icon: (color) => Icon(action.icon, color: color, size: 20),
        ),
    ],
  ),
];

BorderRadiusDirectional _sectionCorners(int index, int length) {
  const corner = Radius.circular(11);
  return BorderRadiusDirectional.horizontal(
    start: index == 0 ? corner : Radius.zero,
    end: index == length - 1 ? corner : Radius.zero,
  );
}

Widget _formatMark(AppearanceAction action, Color color) {
  final style = switch (action.icon) {
    CupertinoIcons.bold => const TextStyle(fontWeight: FontWeight.w700),
    CupertinoIcons.italic => const TextStyle(
      fontFamily: 'Literata',
      fontStyle: FontStyle.italic,
    ),
    CupertinoIcons.underline => const TextStyle(
      decoration: TextDecoration.underline,
    ),
    _ => const TextStyle(decoration: TextDecoration.lineThrough),
  };
  return Text(
    action.title[0],
    style: style.copyWith(fontSize: 20, color: color),
  );
}

SmartContextMenuSimpleItem _editingCell(
  AppearanceAction action, {
  required Widget Function(Color color) icon,
  CupertinoDynamicColor? iconColor,
  BorderRadiusGeometry corners = BorderRadius.zero,
  bool? selected,
  VoidCallback? onTap,
}) => SmartContextMenuItem.simple(
  title: action.title,
  closeOnTap: onTap == null,
  onTap: onTap ?? () => DemoNotice.show('${action.title} (demo only)'),
  customBuilder: (context, state) {
    final showLabel = state.rowSize == SmartContextMenuRowSize.medium;
    final highlighted = selected == true || state.isHovered || state.isPressed;
    final color = highlighted
        ? editingRowsAccent.resolveFrom(context)
        : state.foregroundColor;

    return Semantics(
      label: action.title,
      selected: selected,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: showLabel
              ? null
              : editingRowsSectionColor.resolveFrom(context),
          borderRadius: corners,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: showLabel ? 54 : 44),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: highlighted
                      ? editingRowsSelectionColor.resolveFrom(context)
                      : null,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        icon(iconColor?.resolveFrom(context) ?? color),
                        if (showLabel) ...[
                          const SizedBox(height: 4),
                          _cellLabel(action.title, color),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  },
);

/// Drawing, editing and color tools share one row. Shapes opens its own row.
List<SmartContextMenuItem> drawingToolbarItems(ValueNotifier<String> tool) => [
  SmartContextMenuItem.row(
    size: SmartContextMenuRowSize.small,
    children: [
      for (final action in drawingToolActions)
        SmartContextMenuItem.listenable(
          listenable: tool,
          builder: () => SmartContextMenuItem.simple(
            title: action.title,
            closeOnTap: false,
            onTap: () => tool.value = action.title,
            customBuilder: (context, state) => _toolbarTool(
              context,
              action,
              state,
              selected: tool.value == action.title,
            ),
          ),
        ),
      SmartContextMenuItem.submenu(
        title: 'Shapes',
        customBuilder: (context, state) => _toolbarTool(
          context,
          (title: 'Shapes', icon: CupertinoIcons.square_on_circle),
          state,
          opensSubmenu: true,
        ),
        children: [
          SmartContextMenuItem.row(
            children: [for (final action in shapeActions) _shapeCell(action)],
          ),
        ],
      ),
    ],
  ),
];

Widget _toolbarTool(
  BuildContext context,
  AppearanceAction action,
  SmartContextMenuItemState state, {
  bool? selected,
  bool opensSubmenu = false,
}) {
  final eyedropper = action.icon == CupertinoIcons.eyedropper;
  final iconColor = switch (action.icon) {
    CupertinoIcons.pencil ||
    CupertinoIcons.paintbrush ||
    CupertinoIcons.scribble => drawingToolbarAccent,
    CupertinoIcons.lasso ||
    CupertinoIcons.textformat => drawingToolbarEditingColor,
    CupertinoIcons.square_on_circle => drawingToolbarPaint,
    _ => state.foregroundColor,
  };
  final color = CupertinoDynamicColor.resolve(iconColor, context);
  final surface = drawingToolbarSurface.resolveFrom(context);
  final highlighted = selected == true || state.isHovered || state.isPressed;

  return Semantics(
    label: eyedropper
        ? '${action.title}, current color is apricot'
        : action.title,
    selected: selected,
    excludeSemantics: true,
    child: ColoredBox(
      color: surface,
      child: SizedBox(
        height: 44,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _toolbarIcon(
              context,
              action.icon,
              color,
              surface,
              highlighted: highlighted,
            ),
            if (opensSubmenu)
              PositionedDirectional(
                top: 4,
                end: 3,
                child: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? CupertinoIcons.chevron_back
                      : CupertinoIcons.chevron_forward,
                  size: 9,
                  color: color,
                ),
              ),
            if (eyedropper)
              PositionedDirectional(
                bottom: 5,
                end: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFB48D),
                    border: Border.fromBorderSide(BorderSide(color: surface)),
                  ),
                  child: const SizedBox.square(dimension: 9),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

SmartContextMenuSimpleItem _shapeCell(AppearanceAction action) =>
    SmartContextMenuItem.simple(
      title: action.title,
      onTap: () => DemoNotice.show('${action.title} (demo only)'),
      customBuilder: (context, state) {
        final highlighted = state.isHovered || state.isPressed;
        final surface = drawingToolbarSurface.resolveFrom(context);
        return ColoredBox(
          color: surface,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _toolbarIcon(
                    context,
                    action.icon,
                    drawingToolbarPaint.resolveFrom(context),
                    surface,
                    highlighted: highlighted,
                    size: 34,
                  ),
                  const SizedBox(height: 4),
                  _cellLabel(
                    action.title,
                    highlighted
                        ? drawingToolbarAccent.resolveFrom(context)
                        : state.foregroundColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

Widget _toolbarIcon(
  BuildContext context,
  IconData icon,
  Color color,
  Color surface, {
  required bool highlighted,
  double size = 36,
}) => Container(
  width: size,
  height: size,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: highlighted
        ? Color.alphaBlend(color.withValues(alpha: 0.24), surface)
        : drawingToolbarCapsule.resolveFrom(context),
  ),
  child: Icon(icon, size: 18, color: color),
);

Widget _cellLabel(String title, Color color) => Text(
  title,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
);
