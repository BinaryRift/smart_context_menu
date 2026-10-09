import 'package:flutter/cupertino.dart';

import '../../appearance/ui/appearance_page.dart';
import '../../chat/ui/chat_page.dart';
import '../../files/ui/files_page.dart';
import '../../lab/ui/lab_page.dart';

typedef _Tab = ({String label, IconData icon, Widget page});

const _tabs = <_Tab>[
  (label: 'Files', icon: CupertinoIcons.folder, page: FilesPage()),
  (label: 'Chat', icon: CupertinoIcons.chat_bubble_2, page: ChatPage()),
  (
    label: 'Appearance',
    icon: CupertinoIcons.paintbrush,
    page: AppearancePage(),
  ),
  (label: 'Lab', icon: CupertinoIcons.lab_flask, page: LabPage()),
];

/// The tabs of the app, each with its own navigation stack.
final class TabsPage extends StatelessWidget {
  const TabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
      tabBuilder: (context, index) =>
          CupertinoTabView(builder: (context) => _tabs[index].page),
    );
  }
}
