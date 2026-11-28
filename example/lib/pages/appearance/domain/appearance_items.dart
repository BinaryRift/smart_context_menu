// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../core/data/demo_loader.dart';
import '../../../core/ui/demo_notice.dart';
import '../../../resources/app_theme/tint_colors.dart';
import '../ui/appearance_styles.dart';
import '../ui/theme_styles.dart';
import '../ui/widgets/count_badge.dart';
import '../ui/widgets/tag_color_row.dart';

/// The same items in most presets, so the difference in style is seen:
/// icons, a submenu, an item that loads, a disabled item, a separator
/// and a destructive item.
List<SmartContextMenuItem> sampleItems(DemoLoader loader) => [
  _action('Copy', CupertinoIcons.doc_on_doc),
  SmartContextMenuItem.submenu(
    title: 'Share',
    leading: const Icon(CupertinoIcons.share),
    children: [
      _action('Messages', CupertinoIcons.chat_bubble),
      _action('Mail', CupertinoIcons.mail),
    ],
  ),
  SmartContextMenuItem.async(
    asyncItem: () async {
      await loader.load('Pin');
      return _action('Pin', CupertinoIcons.pin);
    },
  ),
  _action('Archive', CupertinoIcons.archivebox, isDisabled: true),
  SmartContextMenuItem.separator(),
  _action('Delete', CupertinoIcons.delete, isDestructive: true),
];

/// Items with their own content: a row of buttons and two lines of text,
/// items tinted with their own colors and a separator with a title; the
/// preset adds dividers between the items.
List<SmartContextMenuItem> customContentItems(
  ValueNotifier<Color> tagColor,
) => [
  _action('Rename', CupertinoIcons.pencil),
  _titledSeparator('Organize'),
  _action(
    'Favorite',
    CupertinoIcons.heart,
    tintColor: readableTint(CupertinoColors.systemPurple),
  ),
  _action(
    'Mark as done',
    CupertinoIcons.checkmark_circle,
    tintColor: readableTint(CupertinoColors.systemGreen),
  ),
  // The buttons handle their own taps. The item has no action and does
  // not close the menu, so it is not highlighted and a tap next to the
  // buttons does nothing.
  SmartContextMenuItem.simple(
    closeOnTap: false,
    customBuilder: (context, state) =>
        TagColorRow(selected: tagColor, foregroundColor: state.foregroundColor),
  ),
  SmartContextMenuItem.simple(
    onTap: () => DemoNotice.show('Version history (demo only)'),
    customBuilder: (context, state) => Row(
      children: [
        Icon(CupertinoIcons.clock, color: state.foregroundColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version history',
                style: TextStyle(fontSize: 17, color: state.foregroundColor),
              ),
              Text(
                'Edited 5 minutes ago',
                style: TextStyle(
                  fontSize: 13,
                  color: state.foregroundColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
  SmartContextMenuItem.separator(),
  _action('Delete', CupertinoIcons.delete, isDestructive: true),
];

/// Items in Russian, with the strings the menu shows itself in Russian too.
///
/// [failingLoader] fails every other time, so the first load shows the error
/// and the retry; the archive is an empty submenu with the back item.
List<SmartContextMenuItem> russianItems(DemoLoader failingLoader) => [
  _russianAction('Копировать', CupertinoIcons.doc_on_doc),
  SmartContextMenuItem.submenu(
    title: 'Поделиться',
    leading: const Icon(CupertinoIcons.share),
    children: [
      _russianAction('Сообщения', CupertinoIcons.chat_bubble),
      _russianAction('Почта', CupertinoIcons.mail),
    ],
  ),
  SmartContextMenuItem.async(
    asyncItem: () async {
      await failingLoader.load('Закрепить');
      return _russianAction('Закрепить', CupertinoIcons.pin);
    },
  ),
  SmartContextMenuItem.asyncSubmenu(
    title: 'Архив',
    leading: const Icon(CupertinoIcons.archivebox),
    asyncChildren: () async {
      await Future<void>.delayed(demoLoadDelay);
      return [];
    },
  ),
  SmartContextMenuItem.separator(),
  _russianAction('Удалить', CupertinoIcons.delete, isDestructive: true),
];

/// Loading, error and empty items with the icons of the preset.
///
/// [failingLoader] fails every other time, so the first load shows
/// the error and the retry.
List<SmartContextMenuItem> statusItems(DemoLoader failingLoader) => [
  SmartContextMenuItem.loading(title: 'Syncing'),
  SmartContextMenuItem.async(
    asyncItem: () async {
      await failingLoader.load('Pin');
      return _action('Pin', CupertinoIcons.pin);
    },
  ),
  SmartContextMenuItem.asyncSubmenu(
    title: 'Archive',
    leading: const Icon(CupertinoIcons.archivebox),
    asyncChildren: () async {
      await Future<void>.delayed(demoLoadDelay);
      return [];
    },
  ),
];

/// The most used actions as a row above the usual list.
List<SmartContextMenuItem> quickActionItems() => [
  SmartContextMenuItem.row(
    children: [
      _action('Copy', CupertinoIcons.doc_on_doc),
      SmartContextMenuItem.submenu(
        title: 'Share',
        leading: const Icon(CupertinoIcons.share),
        children: [
          _action('Messages', CupertinoIcons.chat_bubble),
          _action('Mail', CupertinoIcons.mail),
        ],
      ),
      _action('Delete', CupertinoIcons.delete, isDestructive: true),
    ],
  ),
  _action('Pin', CupertinoIcons.pin),
  _action('Select', CupertinoIcons.checkmark_circle),
  _action('Rename', CupertinoIcons.pencil),
];

typedef AppearanceAction = ({String title, IconData icon});

const formattingActions = <AppearanceAction>[
  (title: 'Bold', icon: CupertinoIcons.bold),
  (title: 'Italic', icon: CupertinoIcons.italic),
  (title: 'Underline', icon: CupertinoIcons.underline),
  (title: 'Strikethrough', icon: CupertinoIcons.strikethrough),
];

const alignmentActions = <AppearanceAction>[
  (title: 'Align Left', icon: CupertinoIcons.text_alignleft),
  (title: 'Center', icon: CupertinoIcons.text_aligncenter),
  (title: 'Align Right', icon: CupertinoIcons.text_alignright),
  (title: 'Justify', icon: CupertinoIcons.text_justify),
];

const clipboardActions = <AppearanceAction>[
  (title: 'Cut', icon: CupertinoIcons.scissors),
  (title: 'Copy', icon: CupertinoIcons.doc_on_doc),
  (title: 'Paste', icon: CupertinoIcons.doc_on_clipboard),
];

/// A menu of rows only: eight small cells in two rows, a separator and
/// a row of medium cells.
List<SmartContextMenuItem> onlyRowItems() => [
  SmartContextMenuItem.row(
    size: SmartContextMenuRowSize.small,
    children: [
      for (final (:title, :icon) in formattingActions) _action(title, icon),
    ],
  ),
  SmartContextMenuItem.row(
    size: SmartContextMenuRowSize.small,
    children: [
      for (final (:title, :icon) in alignmentActions) _action(title, icon),
    ],
  ),
  SmartContextMenuItem.separator(),
  SmartContextMenuItem.row(
    children: [
      for (final (:title, :icon) in clipboardActions) _action(title, icon),
    ],
  ),
];

const _tagColors = {
  'Red': CupertinoColors.systemRed,
  'Orange': CupertinoColors.systemOrange,
  'Green': CupertinoColors.systemGreen,
  'Blue': CupertinoColors.systemBlue,
  'Purple': CupertinoColors.systemPurple,
};

/// Rows in their own style, see [styledRowStyle]: a cell with a badge,
/// a wider cell, and a row of colors to tag with; the preset adds dividers
/// between the items and the cells.
List<SmartContextMenuItem> styledRowItems(ValueNotifier<Color> tagColor) => [
  SmartContextMenuItem.row(
    children: [
      _inboxItem(unread: 3),
      _action('Flag', CupertinoIcons.flag),
      SmartContextMenuRowFlex(
        flex: 2,
        child: _action('Mark as Read', CupertinoIcons.envelope_open),
      ),
    ],
  ),
  // Built-in cells instead of the own buttons of Custom content: they are
  // highlighted and picked by drag-to-select like other items.
  SmartContextMenuItem.row(
    size: SmartContextMenuRowSize.small,
    dividersBetweenChildren: false,
    padding: const EdgeInsets.all(4),
    children: [
      for (final MapEntry(key: name, value: color) in _tagColors.entries)
        SmartContextMenuItem.listenable(
          listenable: tagColor,
          builder: () => SmartContextMenuItem.simple(
            title: name,
            leading: Icon(
              tagColor.value == color
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle_fill,
            ),
            tintColor: readableTint(color),
            closeOnTap: false,
            onTap: () => tagColor.value = color,
          ),
        ),
    ],
  ),
  _action('Move', CupertinoIcons.folder),
  _action('Delete', CupertinoIcons.delete, isDestructive: true),
];

/// An item with the number of [unread] messages next to its icon, in a
/// cell or in the list.
SmartContextMenuSimpleItem _inboxItem({required int unread}) {
  const icon = Icon(CupertinoIcons.tray);
  final badge = CountBadge(count: unread);

  return SmartContextMenuItem.simple(
    title: 'Inbox',
    onTap: () => DemoNotice.show('Inbox (demo only)'),
    customBuilder: (context, state) {
      final title = Text(
        'Inbox',
        textAlign: state.rowSize == null ? TextAlign.start : TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: SmartContextMenuDefaults.titleStyle
            .merge(state.rowSize == null ? null : styledRowStyle.titleStyle)
            .copyWith(color: state.foregroundColor),
      );
      final iconWithBadge = Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          PositionedDirectional(top: -6, start: 14, child: badge),
        ],
      );

      return IconTheme.merge(
        data: IconThemeData(color: state.foregroundColor),
        child: switch (state.rowSize) {
          null => Row(
            children: [
              icon,
              const SizedBox(width: SmartContextMenuDefaults.itemChildrenGap),
              Expanded(child: title),
              badge,
            ],
          ),
          // Only the built-in content is centered in its cell, at the top.
          SmartContextMenuRowSize.small => Align(
            alignment: Alignment.topCenter,
            heightFactor: 1,
            // The built-in content labels an icon without a title, own
            // content labels itself.
            child: Semantics(label: 'Inbox', child: iconWithBadge),
          ),
          SmartContextMenuRowSize.medium => Align(
            alignment: Alignment.topCenter,
            heightFactor: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWithBadge,
                const SizedBox(
                  height: SmartContextMenuDefaults.rowItemChildrenGap,
                ),
                title,
              ],
            ),
          ),
        },
      );
    },
  );
}

const drawingToolActions = <AppearanceAction>[
  (title: 'Pen', icon: CupertinoIcons.pencil),
  (title: 'Brush', icon: CupertinoIcons.paintbrush),
  (title: 'Scribble', icon: CupertinoIcons.scribble),
  (title: 'Lasso', icon: CupertinoIcons.lasso),
  (title: 'Text', icon: CupertinoIcons.textformat),
  (title: 'Eyedropper', icon: CupertinoIcons.eyedropper),
];

const shapeActions = <AppearanceAction>[
  (title: 'Square', icon: CupertinoIcons.square),
  (title: 'Circle', icon: CupertinoIcons.circle),
  (title: 'Triangle', icon: CupertinoIcons.triangle),
  (title: 'Hexagon', icon: CupertinoIcons.hexagon),
  (title: 'Star', icon: CupertinoIcons.star),
];

/// Seven small cells in one row of a wider menu, see [wideRowMenuWidth],
/// and a submenu of one row of medium cells.
List<SmartContextMenuItem> wideRowItems() => [
  SmartContextMenuItem.row(
    size: SmartContextMenuRowSize.small,
    children: [
      for (final (:title, :icon) in drawingToolActions)
        _action(title, icon, leading: _wideRowIcon(icon)),
      SmartContextMenuItem.submenu(
        title: 'Shapes',
        leading: _wideRowIcon(CupertinoIcons.square_on_circle),
        children: [
          SmartContextMenuItem.row(
            children: [
              for (final (:title, :icon) in shapeActions)
                _action(title, icon, leading: _wideRowIcon(icon)),
            ],
          ),
        ],
      ),
    ],
  ),
];

/// The carousel palette with deeper shades for the light theme.
Widget _wideRowIcon(IconData icon) => Builder(
  builder: (context) {
    final color = switch (icon) {
      CupertinoIcons.pencil || CupertinoIcons.square => drawingToolbarAccent,
      CupertinoIcons.paintbrush ||
      CupertinoIcons.circle => const CupertinoDynamicColor.withBrightness(
        color: Color(0xFF225BA9),
        darkColor: Color(0xFF8ABEFF),
      ),
      CupertinoIcons.scribble ||
      CupertinoIcons.triangle => const CupertinoDynamicColor.withBrightness(
        color: Color(0xFFA42B56),
        darkColor: Color(0xFFFFA1C5),
      ),
      CupertinoIcons.lasso ||
      CupertinoIcons.hexagon => drawingToolbarEditingColor,
      CupertinoIcons.textformat ||
      CupertinoIcons.star => const CupertinoDynamicColor.withBrightness(
        color: Color(0xFF8B6300),
        darkColor: Color(0xFFFFE192),
      ),
      CupertinoIcons.eyedropper => const CupertinoDynamicColor.withBrightness(
        color: Color(0xFF415A6B),
        darkColor: Color(0xFFE4F4FB),
      ),
      CupertinoIcons.square_on_circle => drawingToolbarPaint,
      _ => null,
    };
    final leading = Icon(
      icon,
      color: CupertinoDynamicColor.maybeResolve(color, context),
    );
    if (icon != CupertinoIcons.eyedropper) return leading;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        leading,
        PositionedDirectional(
          end: -2,
          bottom: 0,
          child: Semantics(
            label: 'Current color is apricot',
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFFB48D),
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(dimension: 5),
            ),
          ),
        ),
      ],
    );
  },
);

/// A separator of a thin line with [title] in the middle.
SmartContextMenuSeparatorItem _titledSeparator(String title) {
  return SmartContextMenuItem.separator(
    child: Builder(
      builder: (context) {
        final line = Expanded(
          child: Container(
            height: 1,
            color: CupertinoDynamicColor.resolve(
              SmartContextMenuDefaults.dividerColor,
              context,
            ),
          ),
        );
        // The item above has its own padding, the tinted item below fills
        // its padding with color: the space below evens them out.
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              line,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.secondaryLabel,
                      context,
                    ),
                  ),
                ),
              ),
              line,
            ],
          ),
        );
      },
    ),
  );
}

SmartContextMenuSimpleItem _action(
  String title,
  IconData icon, {
  bool isDestructive = false,
  bool isDisabled = false,
  Color? tintColor,
  Widget? leading,
  String? notice,
}) {
  return SmartContextMenuItem.simple(
    title: title,
    leading: leading ?? Icon(icon),
    isDestructive: isDestructive,
    isDisabled: isDisabled,
    tintColor: tintColor,
    onTap: () => DemoNotice.show(notice ?? '$title (demo only)'),
  );
}

SmartContextMenuSimpleItem _russianAction(
  String title,
  IconData icon, {
  bool isDestructive = false,
}) => _action(
  title,
  icon,
  isDestructive: isDestructive,
  notice: '$title (только демонстрация)',
);
