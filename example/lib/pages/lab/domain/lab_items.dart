import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../core/data/demo_loader.dart';

const _pageCount = 5;
const _pageSize = 20;
const _downloadTick = Duration(milliseconds: 500);
const _downloadStep = 10;

/// A favorite mark that is saved with a delay, like a network request.
class DemoFavorite extends ChangeNotifier {
  bool _isFavorite = false;
  bool _isSaving = false;

  bool get isFavorite => _isFavorite;
  bool get isSaving => _isSaving;

  Future<void> toggle() async {
    _isSaving = true;
    notifyListeners();
    await Future<void>.delayed(demoLoadDelay);
    _isFavorite = !_isFavorite;
    _isSaving = false;
    notifyListeners();
  }
}

/// A download that keeps running after the menu closes.
class DemoDownload extends ChangeNotifier {
  Timer? _timer;
  int _percent = 0;

  bool get isRunning => _timer != null;
  bool get isDone => _percent == 100;
  int get percent => _percent;

  void start() {
    _timer = Timer.periodic(_downloadTick, (timer) {
      _percent += _downloadStep;
      if (isDone) {
        timer.cancel();
        _timer = null;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void remove() {
    _percent = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Items built from the state of the app, also while the menu is open.
List<SmartContextMenuItem> listenableItems({
  required DemoFavorite favorite,
  required ValueNotifier<bool> isMuted,
  required DemoDownload download,
}) => [
  SmartContextMenuItem.listenable(
    listenable: favorite,
    builder: () {
      if (favorite.isSaving) {
        return SmartContextMenuItem.loading(title: 'Saving');
      }
      return SmartContextMenuItem.simple(
        title: favorite.isFavorite
            ? 'Remove from Favorites'
            : 'Add to Favorites',
        leading: Icon(
          favorite.isFavorite
              ? CupertinoIcons.heart_fill
              : CupertinoIcons.heart,
        ),
        closeOnTap: false,
        onTap: favorite.toggle,
      );
    },
  ),
  SmartContextMenuItem.listenable(
    listenable: isMuted,
    builder: () => SmartContextMenuItem.simple(
      title: isMuted.value ? 'Unmute' : 'Mute',
      leading: Icon(
        isMuted.value ? CupertinoIcons.bell_slash : CupertinoIcons.bell,
      ),
      closeOnTap: false,
      onTap: () => isMuted.value = !isMuted.value,
    ),
  ),
  SmartContextMenuItem.separator(),
  SmartContextMenuItem.listenable(
    listenable: download,
    builder: () {
      if (download.isRunning) {
        return SmartContextMenuItem.loading(
          title: 'Downloading ${download.percent}%',
        );
      }
      if (download.isDone) {
        return SmartContextMenuItem.simple(
          title: 'Remove download',
          leading: const Icon(CupertinoIcons.delete),
          isDestructive: true,
          closeOnTap: false,
          onTap: download.remove,
        );
      }
      return SmartContextMenuItem.simple(
        title: 'Download',
        leading: const Icon(CupertinoIcons.cloud_download),
        closeOnTap: false,
        onTap: download.start,
      );
    },
  ),
];

/// Loading, error and empty items, on their own and as states of loads.
///
/// Each load fails every other time, so the first load of the async item
/// and of the shared files fails and can be retried.
List<SmartContextMenuItem> statusItems() {
  final editLoader = DemoLoader()..failEveryOther = true;
  final filesLoader = DemoLoader()..failEveryOther = true;
  return [
    SmartContextMenuItem.loading(title: 'Syncing'),
    SmartContextMenuItem.error(title: 'Could not sync'),
    SmartContextMenuItem.empty(title: 'No drafts'),
    SmartContextMenuItem.separator(),
    SmartContextMenuItem.async(
      asyncItem: () async {
        await editLoader.load('Edit');
        return _action('Edit', icon: CupertinoIcons.pencil);
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
    SmartContextMenuItem.asyncSubmenu(
      title: 'Shared files',
      leading: const Icon(CupertinoIcons.folder_badge_person_crop),
      loading: SmartContextMenuItem.loading(title: 'Loading files'),
      error: SmartContextMenuItem.error(
        child: Row(
          children: [
            const Expanded(child: Text('Could not load files')),
            GestureDetector(
              onTap: () => debugPrint('Tapped: Details'),
              child: const Text(
                'Details',
                style: TextStyle(color: CupertinoColors.activeBlue),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(SmartContextMenuDefaults.retryIcon),
          ],
        ),
      ),
      asyncChildren: () async {
        await filesLoader.load('Shared files');
        return [
          for (var i = 1; i <= 3; i++)
            _action('Shared $i.pdf', icon: CupertinoIcons.doc),
        ];
      },
    ),
  ];
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
      SmartContextMenuItem.separator(),
      _action('Trash', icon: CupertinoIcons.delete, isDestructive: true),
    ],
  ),
  _recentFiles(loader),
  _contacts(loader),
  _share(),
];

/// Three levels: root, Share, Messages.
List<SmartContextMenuItem> nestedLevels() => [
  _action('Copy', icon: CupertinoIcons.doc_on_doc),
  SmartContextMenuItem.separator(),
  _share(),
  SmartContextMenuItem.separator(),
  _action('Delete', icon: CupertinoIcons.delete, isDestructive: true),
];

/// A short root with a long scrollable submenu.
List<SmartContextMenuItem> shortRootLongSubmenu() => [
  _action('Open', icon: CupertinoIcons.arrow_up_right_square),
  SmartContextMenuItem.separator(),
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
    children: [
      _action('Red', tintColor: _deep(CupertinoColors.systemRed)),
      _action('Green', tintColor: _deep(CupertinoColors.systemGreen)),
      _action('Blue', tintColor: _deep(CupertinoColors.systemBlue)),
      _action(
        'Orange',
        tintColor: _deep(CupertinoColors.systemOrange),
        isDisabled: true,
      ),
    ],
  ),
  _action('Rename', icon: CupertinoIcons.pencil),
  _action('Duplicate', icon: CupertinoIcons.plus_square_on_square),
  _action('Pin', icon: CupertinoIcons.pin),
  _action(
    'Favorite',
    icon: CupertinoIcons.heart,
    tintColor: CupertinoColors.systemPurple,
  ),
  _action('Copy link', icon: CupertinoIcons.link),
  _action('Info', icon: CupertinoIcons.info),
  _action('Archive', icon: CupertinoIcons.archivebox, isDisabled: true),
  SmartContextMenuItem.separator(),
  _action('Delete', icon: CupertinoIcons.delete, isDestructive: true),
  _action(
    'Delete forever',
    icon: CupertinoIcons.trash_slash,
    isDestructive: true,
    isDisabled: true,
  ),
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

/// A system color with its darker high contrast variant in the light theme.
CupertinoDynamicColor _deep(CupertinoDynamicColor color) {
  return CupertinoDynamicColor.withBrightness(
    color: color.highContrastColor,
    darkColor: color.darkColor,
  );
}

SmartContextMenuSimpleItem _action(
  String title, {
  IconData? icon,
  bool isDestructive = false,
  bool isDisabled = false,
  Color? tintColor,
  SmartContextMenuPagingMetadata? pagingMetadata,
}) {
  return SmartContextMenuItem.simple(
    title: title,
    leading: icon == null ? null : Icon(icon),
    isDestructive: isDestructive,
    isDisabled: isDisabled,
    tintColor: tintColor,
    pagingMetadata: pagingMetadata,
    onTap: () => debugPrint('Tapped: $title'),
  );
}
