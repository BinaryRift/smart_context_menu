# smart_context_menu example

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

The example app has four tabs: Files, Chat, Appearance, and Lab. Run it with
`flutter run` from the `example` directory. Read [the example app README](https://github.com/BinaryRift/smart_context_menu/blob/v1.0.2/example/README.md)
for details, or [try the live demo](https://thenothingworks.dev/demo/smart-context-menu/).
