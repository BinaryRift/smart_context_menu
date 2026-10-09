# smart_context_menu example

## A minimal menu

Long press the bubble to open its menu; `Share` opens a submenu.

```dart
import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() => runApp(const CupertinoApp(home: MessagePage()));

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: SmartContextMenu(
          items: [
            SmartContextMenuItem.simple(
              title: 'Copy',
              leading: const Icon(CupertinoIcons.doc_on_doc),
              onTap: () => debugPrint('Copy'),
            ),
            SmartContextMenuItem.submenu(
              title: 'Share',
              leading: const Icon(CupertinoIcons.share),
              children: [
                SmartContextMenuItem.simple(
                  title: 'Messages',
                  onTap: () => debugPrint('Share to Messages'),
                ),
                SmartContextMenuItem.simple(
                  title: 'Mail',
                  onTap: () => debugPrint('Share to Mail'),
                ),
              ],
            ),
            SmartContextMenuItem.separator(),
            SmartContextMenuItem.simple(
              title: 'Delete',
              leading: const Icon(CupertinoIcons.delete),
              isDestructive: true,
              onTap: () => debugPrint('Delete'),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Long press me',
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
        ),
      ),
    );
  }
}
```

## The example app

The app in this folder shows every feature of the package on four tabs. Run it with
`flutter run` in this folder. Loads and item taps are logged with `debugPrint`, so you can
see, for example, that a paginated submenu loads its pages only on scroll.

The gear in the navigation bar opens the settings of all menus: the theme, haptics, swipe back,
moving the widget back down after a submenu, and slow animations. They are applied with
one `SmartContextMenuTheme` above the app (`lib/main.dart`).

### Files

Basic menus on files in a grid and a list ([files_page.dart](lib/pages/files/ui/files_page.dart)).

- The grid shows where the menu goes for a widget on the left, in the middle and on the right.
- `Open` and a tap on the preview open the file: an item can open a page.
- `Share` is a submenu with `Messages` inside that loads the contacts; `Move to` loads the folders.
- `Add to Favorites` is a listenable item: it shows saving and then the new title without closing the menu.
- `Rename` is disabled in read-only files; `Delete` is destructive, after a separator.
- The `⋯` button in a row opens the same menu from code with `SmartContextMenuController`.

### Chat

A group chat with messages of different sizes on both sides ([chat_page.dart](lib/pages/chat/ui/chat_page.dart)).

- A reactions bar above every message, pinned to the top while a tall photo and its menu scroll.
- `Forward` loads the chats; `Pin` is a listenable item.
- `Reactions` lists 240 people page by page as you scroll; `Seen by` loads and turns into a submenu.
- A double tap next to a message opens its menu from code.
- The photos have their own `Hero`: a tap on a photo or on its preview flies it to the photo page.
- The last message is near the bottom edge, so the menu moves it up.

### Appearance

Cards with menus of different looks, each with its own `SmartContextMenuTheme` built from
the config of the app ([appearance_styles.dart](lib/pages/appearance/ui/appearance_styles.dart)):
brand colors, an opaque menu, a compact menu, dividers between items, custom item content,
the strings of the menu in Russian and custom loading, error and empty signs.

### Lab

Menus for checking edge cases ([lab_page.dart](lib/pages/lab/ui/lab_page.dart)): every kind of submenu,
menus opened from code, listenable and status items, levels of different heights, a tall widget
and a widget near the bottom edge. Options on the page add header slivers, pin them, delay them,
add dividers and make every other load fail.
