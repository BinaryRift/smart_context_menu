/// Strings shown by the menu itself.
///
/// Override them to localize the menu, for example in the config of
/// a [SmartContextMenuTheme] to localize all menus at once:
///
/// ```dart
/// const SmartContextMenuConfig(
///   labels: SmartContextMenuLabels(
///     back: 'Atrás',
///     retry: 'Reintentar',
///     loading: 'Cargando…',
///     error: 'No se pudo cargar',
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

  /// The title of a [SmartContextMenuItem.loading] item without its own
  /// title, for example the default loading item of
  /// a [SmartContextMenuItem.async] item.
  /// Defaults to `'Loading…'`.
  final String loading;

  /// The title of a [SmartContextMenuItem.error] item without its own title.
  ///
  /// Defaults to `'Could not load'`.
  final String error;

  /// Creates the strings of the menu.
  const SmartContextMenuLabels({
    this.back = "Back",
    this.retry = "Try again",
    this.loading = "Loading…",
    this.error = "Could not load",
  });
}
