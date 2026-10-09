import 'package:flutter/cupertino.dart';

import '../../settings/ui/widgets/settings_button.dart';

final class FilesPage extends StatelessWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Files'),
        trailing: SettingsButton(),
      ),
      child: Center(child: Text('Coming soon')),
    );
  }
}
