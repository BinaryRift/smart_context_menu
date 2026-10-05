/// Strings shown by the menu itself.
///
/// Override them to localize the menu:
///
/// ```dart
/// const SmartContextMenuConfig(
///   labels: SmartContextMenuLabels(
///     back: 'Atrás',
///     retry: 'Reintentar',
///     loading: 'Cargando…',
///   ),
/// )
/// ```
final class SmartContextMenuLabels {
  /// The title of the back item in a submenu.
  ///
  /// Defaults to `'Back'`.
  final String back;

  /// The title of the item that retries a failed load.
  ///
  /// Shown when a submenu or a [SmartContextMenuItem.async] item fails
  /// to load. Defaults to `'Try again'`.
  final String retry;

  /// The title of a [SmartContextMenuItem.async] placeholder while it loads.
  ///
  /// Used when the placeholder has no `loadingTitle`.
  /// Defaults to `'Loading…'`.
  final String loading;

  /// Creates the strings of the menu.
  const SmartContextMenuLabels({
    this.back = "Back",
    this.retry = "Try again",
    this.loading = "Loading…",
  });
}
