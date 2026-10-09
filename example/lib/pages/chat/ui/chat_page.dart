import 'package:flutter/cupertino.dart';

import '../../settings/ui/widgets/settings_button.dart';

final class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Chat'),
        trailing: SettingsButton(),
      ),
      child: Center(child: Text('Coming soon')),
    );
  }
}
