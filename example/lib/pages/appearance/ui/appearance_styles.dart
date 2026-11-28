// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:smart_context_menu/smart_context_menu.dart';

/// Indigo with white text, rounder corners and a dimmed backdrop.
const brandStyle = SmartContextMenuStyle(
  glassStyle: SmartContextMenuGlassStyle(
    color: CupertinoDynamicColor.withBrightness(
      color: Color(0xBC4338CA),
      darkColor: Color(0xA62D248E),
    ),
    edgeHighlight: 0.7,
    border: BorderSide(
      color: CupertinoDynamicColor.withBrightness(
        color: Color(0x669E97FF),
        darkColor: Color(0x808F85FF),
      ),
    ),
  ),
  backgroundColor: CupertinoDynamicColor.withBrightness(
    color: Color(0x7314133D),
    darkColor: Color(0x9914133D),
  ),
  backgroundBlur: null,
  standardStyle: SmartContextMenuStandardStyle(
    color: Color(0xFF4338CA),
    border: BorderSide.none,
    showEdgeHighlight: false,
  ),
  borderRadius: BorderRadius.all(Radius.circular(20)),
  titleStyle: TextStyle(fontSize: 17, color: CupertinoColors.white),
  disabledForegroundColor: Color(0x80FFFFFF),
  destructiveColor: Color(0xFFFF8A8A),
  highlightColor: Color(0x33FFFFFF),
  separatorColor: Color(0x33FFFFFF),
);

/// Thin lines between items with the same space on both sides.
const insetDividersStyle = SmartContextMenuStyle(
  standardStyle: SmartContextMenuStandardStyle(border: BorderSide.none),
  dividersBetweenItems: true,
  dividerIndent: 16,
  dividerEndIndent: 16,
);

/// Own signs of loading, error and empty items, with the titles at the
/// start rather than in the middle: a Material progress indicator instead
/// of the Cupertino one, and other icons.
const statusItemsStyle = SmartContextMenuStyle(
  standardStyle: SmartContextMenuStandardStyle(border: BorderSide.none),
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
