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
///     empty: 'No hay elementos',
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
  /// to load, unless its [SmartContextMenuItem.error] item has its own
  /// title. Defaults to `'Try again'`.
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

  /// The title of a [SmartContextMenuItem.empty] item without its own title.
  ///
  /// Defaults to `'No items'`.
  final String empty;

  /// The title of a loading cell of a [SmartContextMenuItem.row] without its
  /// own title, instead of [loading].
  ///
  /// Shown in a [SmartContextMenuRowSize.medium] row. Defaults to
  /// `'Loading…'`.
  final String rowLoading;

  /// The title of an error cell of a [SmartContextMenuItem.row] without its
  /// own title, instead of [error].
  ///
  /// Shown in a [SmartContextMenuRowSize.medium] row. Defaults to `'Error'`.
  final String rowError;

  /// The title of a cell of a [SmartContextMenuItem.row] that retries
  /// a failed load, instead of [retry].
  ///
  /// Shown in a [SmartContextMenuRowSize.medium] row, unless the error item
  /// has its own title. Defaults to `'Retry'`.
  final String rowRetry;

  /// The title of an empty cell of a [SmartContextMenuItem.row] without its
  /// own title, instead of [empty].
  ///
  /// Shown in a [SmartContextMenuRowSize.medium] row. Defaults to
  /// `'No items'`.
  final String rowEmpty;

  /// Creates the strings of the menu.
  const SmartContextMenuLabels({
    this.back = "Back",
    this.retry = "Try again",
    this.loading = "Loading…",
    this.error = "Could not load",
    this.empty = "No items",
    this.rowLoading = "Loading…",
    this.rowError = "Error",
    this.rowRetry = "Retry",
    this.rowEmpty = "No items",
  });
}
