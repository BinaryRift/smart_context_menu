import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../core/data/demo_loader.dart';
import '../../../resources/app_theme/tint_colors.dart';
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
    onTap: () => debugPrint('Tapped: Version history'),
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
  _action('Копировать', CupertinoIcons.doc_on_doc),
  SmartContextMenuItem.submenu(
    title: 'Поделиться',
    leading: const Icon(CupertinoIcons.share),
    children: [
      _action('Сообщения', CupertinoIcons.chat_bubble),
      _action('Почта', CupertinoIcons.mail),
    ],
  ),
  SmartContextMenuItem.async(
    asyncItem: () async {
      await failingLoader.load('Закрепить');
      return _action('Закрепить', CupertinoIcons.pin);
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
  _action('Удалить', CupertinoIcons.delete, isDestructive: true),
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
}) {
  return SmartContextMenuItem.simple(
    title: title,
    leading: Icon(icon),
    isDestructive: isDestructive,
    isDisabled: isDisabled,
    tintColor: tintColor,
    onTap: () => debugPrint('Tapped: $title'),
  );
}
