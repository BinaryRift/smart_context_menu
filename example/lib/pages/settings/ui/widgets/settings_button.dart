import 'package:flutter/cupertino.dart';

import '../settings_sheet.dart';

/// A gear for the navigation bar that opens the settings.
final class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => showSettingsSheet(context),
      child: const Icon(CupertinoIcons.gear),
    );
  }
}
