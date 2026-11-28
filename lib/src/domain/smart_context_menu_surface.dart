/// Selects which surface a [SmartContextMenuStyle] uses.
///
/// The surface is chosen on each opening. A change to
/// [SmartContextMenuStyle.surface] keeps both surface styles available.
enum SmartContextMenuSurface {
  /// Uses Liquid Glass with [SmartContextMenuStyle.glassStyle].
  ///
  /// The menu uses [standard] while the shader is unavailable or when the
  /// anchor requests high contrast.
  glass,

  /// Uses the standard panel with [SmartContextMenuStyle.standardStyle].
  standard,
}
