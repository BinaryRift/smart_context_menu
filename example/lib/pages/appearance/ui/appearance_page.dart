import 'package:flutter/cupertino.dart';

import '../../settings/ui/widgets/settings_button.dart';

final class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Appearance'),
        trailing: SettingsButton(),
      ),
      child: Center(child: Text('Coming soon')),
    );
  }
}
