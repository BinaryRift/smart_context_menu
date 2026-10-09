import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../core/data/demo_loader.dart';
import '../../../core/ui/reactions_bar.dart';
import '../../../resources/assets/app_images.dart';
import '../../detail/ui/detail_page.dart';
import '../../settings/ui/widgets/settings_button.dart';
import '../domain/chat.dart';
import '../domain/chat_message.dart';
import '../domain/demo_chat.dart';
import 'chat_colors.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_footer.dart';

const _reactionsPageSize = 20;

/// A group chat with messages of different sizes on both sides.
///
/// Each message has a reactions bar above it and a menu below it.
/// A tall photo and its menu do not fit on the screen and scroll together;
/// the last message is near the bottom edge, so the menu moves it up.
final class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

final class _ChatPageState extends State<ChatPage> {
  final _chat = Chat();
  final _loader = DemoLoader();

  @override
  void dispose() {
    _chat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ChatColors.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Hiking club'),
        trailing: SettingsButton(),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListenableBuilder(
                listenable: _chat,
                builder: (context, _) => ListView.builder(
                  // Starts at the newest message, at the bottom.
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: _chat.messages.length,
                  itemBuilder: (context, index) {
                    final messages = _chat.messages;
                    return _buildMessage(messages[messages.length - 1 - index]);
                  },
                ),
              ),
            ),
            const ChatInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final image = message.image;
    final secondaryLabel = CupertinoDynamicColor.resolve(
      CupertinoColors.secondaryLabel,
      context,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: message.isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (message.author case final author?)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 2),
              child: Text(
                author,
                style: TextStyle(fontSize: 13, color: secondaryLabel),
              ),
            ),
          SmartContextMenu(
            items: _menuItems(message),
            headerSliversBuilder: _reactionsBar(message),
            onPreviewTap: image == null ? null : () => _openPhoto(image),
            child: MessageBubble(message: message),
          ),
          MessageFooter(message: message, isPinned: _chat.isPinned(message)),
        ],
      ),
    );
  }

  /// Reactions above the message that scale in from its edge. They stay
  /// at the top while a tall message and its menu scroll.
  SmartContextMenuHeaderBuilder _reactionsBar(ChatMessage message) {
    return (context, header) => [
      PinnedHeaderSliver(
        child: Align(
          alignment: header.alignment,
          child: ScaleTransition(
            scale: header.animation.drive(
              CurveTween(curve: Curves.easeOutBack),
            ),
            // Grows from the bottom edge, next to the message.
            alignment: Alignment(header.alignment.x, 1),
            child: ReactionsBar(
              onSelected: (reaction) async {
                await header.close();
                _chat.react(message, reaction);
              },
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
    ];
  }

  List<SmartContextMenuItem> _menuItems(ChatMessage message) => [
    _action('Reply', CupertinoIcons.reply),
    if (message.image == null)
      _action('Copy', CupertinoIcons.doc_on_doc)
    else
      _action('Save', CupertinoIcons.arrow_down_to_line),
    _forwardItem(),
    _pinItem(message),
    if (message.reactionCount > 0) _reactionsItem(message),
    if (message.isMine) _seenByItem(),
    SmartContextMenuItem.separator(),
    _action('Delete', CupertinoIcons.delete, isDestructive: true),
  ];

  /// A submenu loaded when it opens.
  SmartContextMenuItem _forwardItem() {
    return SmartContextMenuItem.asyncSubmenu(
      title: 'Forward',
      leading: const Icon(CupertinoIcons.arrowshape_turn_up_right),
      asyncChildren: () async {
        await _loader.load('Chats');
        return [for (final chat in chats) _action(chat, null)];
      },
    );
  }

  /// Rebuilds from [_chat] while the menu is open.
  SmartContextMenuItem _pinItem(ChatMessage message) {
    return SmartContextMenuItem.listenable(
      listenable: _chat,
      builder: () {
        final isPinned = _chat.isPinned(message);
        return SmartContextMenuItem.simple(
          title: isPinned ? 'Unpin' : 'Pin',
          leading: Icon(
            isPinned ? CupertinoIcons.pin_slash : CupertinoIcons.pin,
          ),
          closeOnTap: false,
          onTap: () => _chat.togglePin(message),
        );
      },
    );
  }

  /// A submenu that loads the next page of people when it scrolls
  /// to the end.
  SmartContextMenuItem _reactionsItem(ChatMessage message) {
    final count = message.reactionCount;
    return SmartContextMenuItem.pagingSubmenu(
      title: 'Reactions: $count',
      leading: const Icon(CupertinoIcons.smiley),
      initialMetadata: const SmartContextMenuPagingMetadata(
        limit: _reactionsPageSize,
      ),
      asyncPagingChildren: (metadata) async {
        await _loader.load('Reactions, page ${metadata.page}');
        final first = (metadata.page - 1) * metadata.limit;
        final last = min(first + metadata.limit, count);
        return [
          for (var i = first; i < last; i++)
            SmartContextMenuItem.simple(
              title: personName(i),
              trailing: Text(reactionAt(message, i)),
              // The last item of a page asks for the next one.
              pagingMetadata: i == last - 1 && last < count
                  ? metadata.copyWith(page: metadata.page + 1)
                  : null,
            ),
        ];
      },
    );
  }

  /// An async item that turns into a submenu once loaded.
  SmartContextMenuItem _seenByItem() {
    return SmartContextMenuItem.async(
      loading: SmartContextMenuItem.loading(title: 'Seen by'),
      asyncItem: () async {
        await _loader.load('Seen by');
        return SmartContextMenuItem.submenu(
          title: 'Seen by ${readers.length}',
          leading: const Icon(CupertinoIcons.eye),
          children: [for (final reader in readers) _action(reader, null)],
        );
      },
    );
  }

  SmartContextMenuSimpleItem _action(
    String title,
    IconData? icon, {
    bool isDestructive = false,
  }) {
    return SmartContextMenuItem.simple(
      title: title,
      leading: icon == null ? null : Icon(icon),
      isDestructive: isDestructive,
      onTap: () => debugPrint('Tapped: $title'),
    );
  }

  void _openPhoto(AppImage image) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => DetailPage(
          title: 'Photo',
          child: InteractiveViewer(child: Image.asset(image.path)),
        ),
      ),
    );
  }
}
