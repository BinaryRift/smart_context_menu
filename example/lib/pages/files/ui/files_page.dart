import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart' show SliverConstraints;
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../core/data/demo_loader.dart';
import '../../../core/ui/demo_notice.dart';
import '../../detail/ui/detail_page.dart';
import '../../settings/ui/widgets/settings_button.dart';
import '../domain/demo_file.dart';
import '../domain/demo_files.dart';
import '../domain/file_downloads.dart';
import '../domain/file_favorites.dart';
import 'widgets/file_icon.dart';
import 'widgets/file_row.dart';
import 'widgets/file_tile.dart';

/// The widest a tile of the grid gets: a phone fits three of them in a row,
/// a tablet six.
const _tileExtent = 130.0;

/// Files in a grid and a list, each with the same menu.
///
/// The grid shows where the menu goes for a widget on the left, in the
/// middle and on the right of the screen; the list shows the menu opened
/// from the button in a row and near the bottom edge.
final class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

final class _FilesPageState extends State<FilesPage> {
  final _loader = DemoLoader();
  final _favorites = FileFavorites();
  final _downloads = FileDownloads();

  /// Open the menus of the rows from their buttons.
  final _rowMenus = {
    for (final file in documents) file: SmartContextMenuController(),
  };

  @override
  void dispose() {
    _favorites.dispose();
    _downloads.dispose();
    for (final controller in _rowMenus.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Files'),
        trailing: SettingsButton(),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(
              'Recent',
              hint: 'Press and hold a file to open its menu',
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverLayoutBuilder(builder: _buildRecentFiles),
            ),
            _buildHeader(
              'Documents',
              hint: 'Or use ⋯ on a file to open its menu',
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList.separated(
                itemCount: documents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final file = documents[index];
                  final menu = _rowMenus[file]!;
                  return _buildMenu(
                    file,
                    controller: menu,
                    child: FileRow(
                      file: file,
                      favorites: _favorites,
                      onMore: menu.open,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Two rows of the most recent files, as many in a row as fit.
  Widget _buildRecentFiles(
    BuildContext context,
    SliverConstraints constraints,
  ) {
    final columns = max(3, (constraints.crossAxisExtent / _tileExtent).floor());
    return SliverGrid.count(
      crossAxisCount: columns,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        for (final file in documents.take(columns * 2))
          _buildMenu(
            file,
            child: FileTile(file: file, favorites: _favorites),
          ),
      ],
    );
  }

  Widget _buildHeader(String title, {required String hint}) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 4),
            Text(
              hint,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 13,
                color: CupertinoDynamicColor.resolve(
                  CupertinoColors.secondaryLabel,
                  context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A tap on [child] opens [file]; a long press or [controller] opens its menu.
  Widget _buildMenu(
    DemoFile file, {
    required Widget child,
    SmartContextMenuController? controller,
  }) {
    return SmartContextMenu(
      controller: controller,
      items: _menuItems(file),
      // A tap on the lifted file opens it, like a tap on the file itself.
      onPreviewTap: () => _open(file),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(file),
        child: child,
      ),
    );
  }

  List<SmartContextMenuItem> _menuItems(DemoFile file) => [
    SmartContextMenuItem.simple(
      title: 'Open',
      leading: const Icon(CupertinoIcons.arrow_up_right_square),
      // Runs when the menu is almost closed, so it can open a page.
      onTap: () => _open(file),
    ),
    _shareItem(file),
    _moveToItem(file),
    _favoriteItem(file),
    _downloadItem(file),
    SmartContextMenuItem.simple(
      title: 'Rename',
      leading: const Icon(CupertinoIcons.pencil),
      isDisabled: file.isReadOnly,
      onTap: () => _notice('Rename ${file.name} (demo only)'),
    ),
    SmartContextMenuItem.separator(),
    SmartContextMenuItem.simple(
      title: 'Delete',
      leading: const Icon(CupertinoIcons.delete),
      isDestructive: true,
      onTap: () => _notice('Delete ${file.name} (demo only)'),
    ),
  ];

  /// A static submenu with an async submenu inside.
  SmartContextMenuItem _shareItem(DemoFile file) {
    return SmartContextMenuItem.submenu(
      title: 'Share',
      leading: const Icon(CupertinoIcons.share),
      children: [
        SmartContextMenuItem.simple(
          title: 'Copy link',
          leading: const Icon(CupertinoIcons.link),
          onTap: () => _notice('Copy link to ${file.name} (demo only)'),
        ),
        SmartContextMenuItem.asyncSubmenu(
          title: 'Messages',
          leading: const Icon(CupertinoIcons.chat_bubble),
          asyncChildren: () async {
            await _loader.load('Contacts');
            return [
              for (final contact in contacts)
                SmartContextMenuItem.simple(
                  title: contact,
                  onTap: () =>
                      _notice('Send ${file.name} to $contact (demo only)'),
                ),
            ];
          },
        ),
        SmartContextMenuItem.simple(
          title: 'Mail',
          leading: const Icon(CupertinoIcons.mail),
          onTap: () => _notice('Mail ${file.name} (demo only)'),
        ),
        SmartContextMenuItem.simple(
          title: 'AirDrop',
          leading: const Icon(CupertinoIcons.antenna_radiowaves_left_right),
          onTap: () => _notice('AirDrop ${file.name} (demo only)'),
        ),
      ],
    );
  }

  /// A submenu loaded when it opens; the current folder is disabled.
  SmartContextMenuItem _moveToItem(DemoFile file) {
    return SmartContextMenuItem.asyncSubmenu(
      title: 'Move to',
      leading: const Icon(CupertinoIcons.folder),
      asyncChildren: () async {
        await _loader.load('Folders');
        return [
          for (final folder in folders)
            SmartContextMenuItem.simple(
              title: folder,
              leading: const Icon(CupertinoIcons.folder),
              isDisabled: folder == file.folder,
              onTap: () => _notice('Move ${file.name} to $folder (demo only)'),
            ),
        ];
      },
    );
  }

  /// Rebuilds from [_favorites] while the menu is open: shows the saving
  /// and then the new title, without closing the menu.
  SmartContextMenuItem _favoriteItem(DemoFile file) {
    return SmartContextMenuItem.listenable(
      listenable: _favorites,
      builder: () {
        if (_favorites.isSaving(file)) {
          return SmartContextMenuItem.loading(title: 'Saving');
        }
        final isFavorite = _favorites.contains(file);
        return SmartContextMenuItem.simple(
          title: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
          leading: Icon(
            isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          ),
          closeOnTap: false,
          onTap: () => _favorites.toggle(file),
        );
      },
    );
  }

  /// Rebuilds from [_downloads] while the menu is open: shows the progress
  /// of the download, which keeps running after the menu closes.
  SmartContextMenuItem _downloadItem(DemoFile file) {
    return SmartContextMenuItem.listenable(
      listenable: _downloads,
      builder: () {
        if (_downloads.isRunning(file)) {
          return SmartContextMenuItem.loading(
            title: 'Downloading ${_downloads.percent(file)}%',
          );
        }
        if (_downloads.isDone(file)) {
          return SmartContextMenuItem.simple(
            title: 'Remove Download',
            leading: const Icon(CupertinoIcons.delete),
            isDestructive: true,
            closeOnTap: false,
            onTap: () => _downloads.remove(file),
          );
        }
        return SmartContextMenuItem.simple(
          title: 'Download',
          leading: const Icon(CupertinoIcons.cloud_download),
          closeOnTap: false,
          onTap: () => _downloads.start(file),
        );
      },
    );
  }

  void _open(DemoFile file) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => DetailPage(
          title: file.name,
          child: FileIcon(kind: file.kind, size: 120),
        ),
      ),
    );
  }

  void _notice(String message) => DemoNotice.show(message);
}
