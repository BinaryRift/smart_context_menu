/// The size of the cells of a [SmartContextMenuItem.row].
enum SmartContextMenuRowSize {
  /// A cell shows only its `leading`, or its `title` without `leading`.
  ///
  /// The `title` is still read by screen readers.
  small,

  /// A cell shows its `leading` above its `title`.
  medium,
}
