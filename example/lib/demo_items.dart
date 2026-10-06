import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

const _loadDelay = Duration(milliseconds: 800);
const _pageCount = 5;
const _pageSize = 20;

/// Simulates network loads of the demo submenus.
class DemoLoader {
  /// Whether every other load fails, so the retry item can be checked.
  bool failEveryOther = false;

  int _attempt = 0;

  Future<void> load(String what) async {
    _attempt++;
    debugPrint('$what: loading');
    await Future<void>.delayed(_loadDelay);
    if (failEveryOther && _attempt.isOdd) {
      debugPrint('$what: failed');
      throw Exception('$what: failed');
    }
  }
}

/// Every kind of submenu: static, async, paginated and nested.
List<SmartContextMenuItem> allSubmenuTypes(DemoLoader loader) => [
  _action('Reply', icon: CupertinoIcons.reply),
  SmartContextMenuItem.submenu(
    title: 'Move to',
    leading: const Icon(CupertinoIcons.folder),
    children: [
      _action('Documents'),
      _action('Archive'),
      _action(
        'Trash',
        icon: CupertinoIcons.delete,
        isDestructive: true,
        hasDivider: true,
      ),
    ],
  ),
  _recentFiles(loader),
  _contacts(loader),
  _share(),
];

/// Three levels: root, Share, Messages.
List<SmartContextMenuItem> nestedLevels() => [
  _action(
    'Copy',
    icon: CupertinoIcons.doc_on_doc,
    hasDivider: true,
    dividerPosition: SmartContextMenuDividerPosition.bottom,
  ),
  _share(),
  _action(
    'Delete',
    icon: CupertinoIcons.delete,
    isDestructive: true,
    hasDivider: true,
  ),
];

/// A short root with a long scrollable submenu.
List<SmartContextMenuItem> shortRootLongSubmenu() => [
  _action(
    'Open',
    icon: CupertinoIcons.arrow_up_right_square,
    hasDivider: true,
    dividerPosition: SmartContextMenuDividerPosition.bottom,
  ),
  SmartContextMenuItem.submenu(
    title: 'Tags',
    leading: const Icon(CupertinoIcons.tag),
    children: [for (var i = 1; i <= 30; i++) _action('Tag $i')],
  ),
];

/// A long root with a short submenu.
List<SmartContextMenuItem> longRootShortSubmenu() => [
  _action('Open', icon: CupertinoIcons.arrow_up_right_square),
  SmartContextMenuItem.submenu(
    title: 'Color',
    leading: const Icon(CupertinoIcons.paintbrush),
    children: [_action('Red'), _action('Blue')],
  ),
  _action('Rename', icon: CupertinoIcons.pencil),
  _action('Duplicate', icon: CupertinoIcons.plus_square_on_square),
  _action('Pin', icon: CupertinoIcons.pin),
  _action('Favorite', icon: CupertinoIcons.heart),
  _action('Copy link', icon: CupertinoIcons.link),
  _action('Info', icon: CupertinoIcons.info),
  _action('Delete', icon: CupertinoIcons.delete, isDestructive: true),
];

SmartContextMenuItem _recentFiles(DemoLoader loader) {
  return SmartContextMenuItem.asyncSubmenu(
    title: 'Recent files',
    leading: const Icon(CupertinoIcons.clock),
    asyncChildren: () async {
      await loader.load('Recent files');
      return [
        for (var i = 1; i <= 6; i++)
          _action('File $i.pdf', icon: CupertinoIcons.doc),
      ];
    },
  );
}

SmartContextMenuItem _contacts(DemoLoader loader) {
  return SmartContextMenuItem.pagingSubmenu(
    title: 'Contacts',
    leading: const Icon(CupertinoIcons.person_2),
    initialMetadata: const SmartContextMenuPagingMetadata(limit: _pageSize),
    asyncPagingChildren: (metadata) async {
      await loader.load('Contacts, page ${metadata.page}');
      final hasMore = metadata.page < _pageCount;
      final first = (metadata.page - 1) * metadata.limit;
      return [
        for (var i = 1; i <= metadata.limit; i++)
          _action(
            'Contact ${first + i}',
            pagingMetadata: i == metadata.limit && hasMore
                ? metadata.copyWith(page: metadata.page + 1)
                : null,
          ),
      ];
    },
  );
}

SmartContextMenuItem _share() {
  return SmartContextMenuItem.submenu(
    title: 'Share',
    leading: const Icon(CupertinoIcons.share),
    children: [
      _action('Copy link', icon: CupertinoIcons.link),
      SmartContextMenuItem.submenu(
        title: 'Messages',
        leading: const Icon(CupertinoIcons.chat_bubble),
        children: [_action('Anna'), _action('Boris'), _action('Chris')],
      ),
      SmartContextMenuItem.submenu(
        title: 'Mail',
        leading: const Icon(CupertinoIcons.mail),
        children: [_action('Work'), _action('Personal')],
      ),
    ],
  );
}

SmartContextMenuItem _action(
  String title, {
  IconData? icon,
  bool isDestructive = false,
  SmartContextMenuPagingMetadata? pagingMetadata,
  bool hasDivider = false,
  SmartContextMenuDividerPosition dividerPosition =
      SmartContextMenuDividerPosition.top,
}) {
  return SmartContextMenuItem.simple(
    title: title,
    leading: icon == null ? null : Icon(icon),
    isDestructive: isDestructive,
    pagingMetadata: pagingMetadata,
    hasDivider: hasDivider,
    dividerPosition: dividerPosition,
    onTap: () => debugPrint('Tapped: $title'),
  );
}
