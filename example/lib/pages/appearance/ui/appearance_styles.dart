// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:smart_context_menu/smart_context_menu.dart';

/// Brand colors with white text and rounder corners, without blur: the
/// screen behind the menu is only dimmed with a dark shade of the brand
/// color.
const brandStyle = SmartContextMenuStyle(
  backgroundColor: CupertinoDynamicColor.withBrightness(
    color: Color(0x7314133D),
    darkColor: Color(0x9914133D),
  ),
  backgroundBlur: null,
  menuColor: Color(0xFF3634A3),
  borderColor: Color(0x00000000),
  borderRadius: BorderRadius.all(Radius.circular(20)),
  titleStyle: TextStyle(fontSize: 17, color: CupertinoColors.white),
  disabledForegroundColor: Color(0x80FFFFFF),
  destructiveColor: Color(0xFFFF6961),
  highlightColor: Color(0x33FFFFFF),
  separatorColor: Color(0x33FFFFFF),
);

/// An opaque menu: its color hides what is behind it, so it needs no blur.
///
/// The back item of a submenu is filled with the same [menuColor], so it
/// blends into the menu.
const solidStyle = SmartContextMenuStyle(
  menuColor: CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF7F7F9),
    darkColor: Color(0xFF2C2C2E),
  ),
);

/// Smaller text and tighter items; the menu is narrower in its config.
const compactStyle = SmartContextMenuStyle(
  itemPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  itemChildrenGap: 8,
  titleStyle: TextStyle(fontSize: 15),
  defaultIconSize: 16,
);

const compactMenuWidth = 200.0;

/// Thin lines between items that start under the titles, as in the lists
/// of iOS: the item padding of 16, the icon of 24 and the gap of 12.
const dividersStyle = SmartContextMenuStyle(
  dividersBetweenItems: true,
  dividerIndent: 52,
);

/// Thin lines between items with the same space on both sides.
const insetDividersStyle = SmartContextMenuStyle(
  dividersBetweenItems: true,
  dividerIndent: 16,
  dividerEndIndent: 16,
);

/// Own signs of loading, error and empty items, with the titles at the
/// start rather than in the middle: a Material progress indicator instead
/// of the Cupertino one, and other icons.
const statusItemsStyle = SmartContextMenuStyle(
  statusStyle: SmartContextMenuStatusStyle(
    loadingIndicator: SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: CupertinoColors.systemOrange,
      ),
    ),
    errorIcon: CupertinoIcons.wifi_exclamationmark,
    retryIcon: CupertinoIcons.arrow_clockwise,
    emptyIcon: CupertinoIcons.tray,
    titleAlign: TextAlign.start,
  ),
);

/// Bolder titles in the cells, gaps between them and vertical lines that
/// stop short of the edges of the row.
const styledRowStyle = SmartContextMenuRowStyle(
  titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  childrenGap: 4,
  dividerIndent: 12,
  dividerEndIndent: 12,
);

/// Wide enough for seven small cells of 48, the touch target of Material
/// and more than the 44 of iOS. A screen narrower than the menu with its
/// screen padding makes the menu narrower: a phone of 360 still leaves
/// about 47 for a cell.
const wideRowMenuWidth = 336.0;

/// The strings the menu shows itself, in Russian.
const russianLabels = SmartContextMenuLabels(
  back: 'Назад',
  retry: 'Повторить',
  loading: 'Загрузка…',
  error: 'Не удалось загрузить',
  empty: 'Пусто',
  rowLoading: 'Загрузка…',
  rowError: 'Ошибка',
  rowRetry: 'Повторить',
  rowEmpty: 'Пусто',
);
