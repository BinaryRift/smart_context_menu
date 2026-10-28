/// How a [SmartContextMenu] opens.
enum SmartContextMenuActivationMode {
  /// Opens on a long press of [SmartContextMenu.child], a secondary click
  /// with a mouse or trackpad, or via [SmartContextMenu.controller].
  ///
  /// The long press is taken: taps, drags and other gestures of
  /// [SmartContextMenu.child] keep working, but its own long press handler
  /// is not called. A secondary pointer-down handler on the child also runs.
  /// A gesture handler that waits for release can be canceled as the menu opens.
  longPress,

  /// Opens only via [SmartContextMenu.controller], which is then required.
  ///
  /// The menu does not listen to gestures of [SmartContextMenu.child],
  /// so it can use the long press and secondary click itself.
  manual,
}
