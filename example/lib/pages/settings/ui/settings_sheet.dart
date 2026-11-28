// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart' show ThemeMode;
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../core/settings/settings_scope.dart';

/// Shows [SettingsSheet] from the bottom of the screen.
Future<void> showSettingsSheet(BuildContext context) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (context) => const SettingsSheet(),
  );
}

/// The settings of the app that apply to all menus.
final class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final textTheme = CupertinoTheme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGroupedBackground,
          context,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Settings', style: textTheme.navTitleTextStyle),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('Theme'),
                  trailing: CupertinoSlidingSegmentedControl<ThemeMode>(
                    groupValue: settings.themeMode,
                    onValueChanged: (mode) {
                      if (mode != null) settings.themeMode = mode;
                    },
                    children: const {
                      ThemeMode.system: Text('System'),
                      ThemeMode.light: Text('Light'),
                      ThemeMode.dark: Text('Dark'),
                    },
                  ),
                ),
                CupertinoListTile(
                  title: const Text('Surface'),
                  trailing:
                      CupertinoSlidingSegmentedControl<SmartContextMenuSurface>(
                        groupValue: settings.surface,
                        onValueChanged: (surface) {
                          if (surface != null) settings.surface = surface;
                        },
                        children: const {
                          SmartContextMenuSurface.glass: Text('Glass'),
                          SmartContextMenuSurface.standard: Text('Standard'),
                        },
                      ),
                ),
                _buildSwitch(
                  title: 'Background blur',
                  subtitle: 'Blur the screen behind open menus',
                  value: settings.enableBackgroundBlur,
                  onChanged: (value) => settings.enableBackgroundBlur = value,
                ),
                _buildSwitch(
                  title: 'Haptics',
                  value: settings.enableHaptics,
                  onChanged: (value) => settings.enableHaptics = value,
                ),
                _buildSwitch(
                  title: 'Swipe back',
                  subtitle: settings.useRtl
                      ? 'Swipe left in a submenu to go back'
                      : 'Swipe right in a submenu to go back',
                  value: settings.enableSwipeBack,
                  onChanged: (value) => settings.enableSwipeBack = value,
                ),
                _buildSwitch(
                  title: 'RTL layout',
                  subtitle: 'Preview the app in right-to-left layout',
                  value: settings.useRtl,
                  onChanged: (value) => settings.useRtl = value,
                ),
                _buildSwitch(
                  title: 'Move back down',
                  subtitle: 'The widget moves down after a taller submenu',
                  value: settings.moveBackDown,
                  onChanged: (value) => settings.moveBackDown = value,
                ),
                _buildSwitch(
                  title: 'Slow animations',
                  value: settings.slowAnimations,
                  onChanged: (value) => settings.slowAnimations = value,
                ),
                _buildSwitch(
                  title: 'Show touches',
                  subtitle: 'A circle under the finger, for screen recordings',
                  value: settings.showTouches,
                  onChanged: (value) => settings.showTouches = value,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CupertinoListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: CupertinoSwitch(value: value, onChanged: onChanged),
    );
  }
}
