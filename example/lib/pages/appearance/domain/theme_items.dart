// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../core/ui/demo_notice.dart';

/// A row of medium cells above the list in the Paper preset.
List<SmartContextMenuItem> paperItems() => [
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
      _action('Pin', CupertinoIcons.pin),
    ],
  ),
  _action('Rename', CupertinoIcons.pencil),
  _action('Move', CupertinoIcons.folder),
  _action('Archive', CupertinoIcons.archivebox, isDisabled: true),
  SmartContextMenuItem.separator(),
  _action('Delete', CupertinoIcons.delete, isDestructive: true),
];

/// The commands of a terminal, in lower case.
List<SmartContextMenuItem> terminalItems() => [
  _action('copy', CupertinoIcons.doc_on_doc),
  SmartContextMenuItem.submenu(
    title: 'share',
    leading: const Icon(CupertinoIcons.share),
    children: [
      _action('messages', CupertinoIcons.chat_bubble),
      _action('mail', CupertinoIcons.mail),
    ],
  ),
  _action('pin', CupertinoIcons.pin),
  _action('archive', CupertinoIcons.archivebox, isDisabled: true),
  SmartContextMenuItem.separator(),
  _action('rm -rf', CupertinoIcons.delete, isDestructive: true),
];

/// The same actions as text only.
List<SmartContextMenuItem> glowItems() => [
  _text('Copy'),
  SmartContextMenuItem.submenu(
    title: 'Share',
    children: [_text('Messages'), _text('Mail')],
  ),
  _text('Rename'),
  _text('Duplicate'),
  _text('Archive', isDisabled: true),
  SmartContextMenuItem.separator(),
  _text('Delete', isDestructive: true),
];

/// A row of small cells, icons only, above a short list.
List<SmartContextMenuItem> compactItems() => [
  SmartContextMenuItem.row(
    size: SmartContextMenuRowSize.small,
    children: [
      _action('Copy', CupertinoIcons.doc_on_doc),
      _action('Share', CupertinoIcons.share),
      _action('Pin', CupertinoIcons.pin),
      _action('Star', CupertinoIcons.star),
      _action('Delete', CupertinoIcons.delete, isDestructive: true),
    ],
  ),
  _action('Rename', CupertinoIcons.pencil),
  _action('Duplicate', CupertinoIcons.plus_square_on_square),
  _action('Move', CupertinoIcons.folder),
  _action('Tags', CupertinoIcons.tag),
  _action('Info', CupertinoIcons.info),
];

/// Icons in colored squares as their own `leading` widgets: the menu
/// leaves the colors of a widget as they are.
List<SmartContextMenuItem> colorfulItems() => [
  _tile('Copy', CupertinoIcons.doc_on_doc, CupertinoColors.systemBlue),
  SmartContextMenuItem.submenu(
    title: 'Share',
    leading: _square(CupertinoIcons.share, CupertinoColors.systemGreen),
    children: [
      _tile(
        'Messages',
        CupertinoIcons.chat_bubble,
        CupertinoColors.systemGreen,
      ),
      _tile('Mail', CupertinoIcons.mail, CupertinoColors.systemBlue),
    ],
  ),
  _tile('Pin', CupertinoIcons.pin, CupertinoColors.systemOrange),
  _tile('Favorite', CupertinoIcons.heart, CupertinoColors.systemPink),
  _tile('Archive', CupertinoIcons.archivebox, CupertinoColors.systemIndigo),
  _tile('Delete', CupertinoIcons.delete, CupertinoColors.systemRed),
];

SmartContextMenuSimpleItem _tile(String title, IconData icon, Color color) {
  return SmartContextMenuItem.simple(
    title: title,
    leading: _square(icon, color),
    onTap: () => DemoNotice.show('$title (demo only)'),
  );
}

Widget _square(IconData icon, Color color) {
  return Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.all(Radius.circular(7)),
    ),
    child: Icon(icon, size: 17, color: CupertinoColors.white),
  );
}

SmartContextMenuSimpleItem _text(
  String title, {
  bool isDestructive = false,
  bool isDisabled = false,
}) {
  return SmartContextMenuItem.simple(
    title: title,
    isDestructive: isDestructive,
    isDisabled: isDisabled,
    onTap: () => DemoNotice.show('$title (demo only)'),
  );
}

SmartContextMenuSimpleItem _action(
  String title,
  IconData icon, {
  bool isDestructive = false,
  bool isDisabled = false,
}) {
  return SmartContextMenuItem.simple(
    title: title,
    leading: Icon(icon),
    isDestructive: isDestructive,
    isDisabled: isDisabled,
    onTap: () => DemoNotice.show('$title (demo only)'),
  );
}
