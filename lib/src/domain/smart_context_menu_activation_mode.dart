/// How a [SmartContextMenu] opens.
enum SmartContextMenuActivationMode {
  /// Opens on a long press of [SmartContextMenu.child] or via
  /// [SmartContextMenu.controller].
  ///
  /// Only the long press is taken: taps, drags and other gestures of
  /// [SmartContextMenu.child] keep working, but its own long press handler
  /// is not called.
  longPress,

  /// Opens only via [SmartContextMenu.controller], which is then required.
  ///
  /// The menu does not listen to gestures of [SmartContextMenu.child],
  /// so it can use the long press itself.
  manual,
}
