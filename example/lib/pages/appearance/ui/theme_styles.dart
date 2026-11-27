import 'dart:ui' as ui show BlurStyle;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

const _terminalGreen = Color(0xFF33FF99);

/// A dark terminal with monospaced green text and a green glow in both themes.
const terminalStyle = SmartContextMenuStyle(
  glassStyle: SmartContextMenuGlassStyle(
    color: CupertinoDynamicColor.withBrightness(
      color: Color(0x800D0D0D),
      darkColor: Color(0x400D0D0D),
    ),
    edgeHighlight: 0.35,
    border: BorderSide(color: Color(0x6633FF99)),
  ),
  standardStyle: SmartContextMenuStandardStyle(
    color: Color(0xFF0D0D0D),
    border: BorderSide(color: Color(0x9933FF99)),
  ),
  borderRadius: BorderRadius.all(Radius.circular(4)),
  menuShadows: [
    BoxShadow(
      color: Color(0x5933FF99),
      blurRadius: 24,
      blurStyle: ui.BlurStyle.outer,
    ),
  ],
  backgroundColor: Color(0x99000000),
  backgroundBlur: null,
  titleStyle: TextStyle(
    fontSize: 16,
    fontFamily: 'JetBrains Mono',
    color: _terminalGreen,
  ),
  disabledForegroundColor: Color(0x6633FF99),
  destructiveColor: Color(0xFFFF5F56),
  highlightColor: Color(0x2633FF99),
  separatorColor: Color(0x6633FF99),
  dividerColor: Color(0x6633FF99),
  separatorThickness: 1,
  submenuIcon: CupertinoIcons.chevron_right_2,
);

/// Small text, tight items and dividers; the menu is narrower in its
/// config.
const compactStyle = SmartContextMenuStyle(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  itemPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
  itemChildrenGap: 8,
  titleStyle: TextStyle(fontSize: 14),
  defaultIconSize: 14,
  dividersBetweenItems: true,
  separatorThickness: 4,
);

/// Fits five small cells of 36.
const compactMenuWidth = 190.0;

/// Neutral surfaces and a soft backdrop for icons in colored squares.
const colorfulStyle = SmartContextMenuStyle(
  glassStyle: SmartContextMenuGlassStyle(
    color: CupertinoDynamicColor.withBrightness(
      color: Color(0xA6F7FAFF),
      darkColor: Color(0xB324252B),
    ),
    blur: SmartContextMenuBlur.none,
  ),
  standardStyle: SmartContextMenuStandardStyle(
    color: CupertinoDynamicColor.withBrightness(
      color: Color(0xFFFFFFFF),
      darkColor: Color(0xFF1C1C1E),
    ),
    border: BorderSide.none,
  ),
  borderRadius: BorderRadius.all(Radius.circular(18)),
  menuShadows: [
    BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 16)),
  ],
  backgroundColor: CupertinoDynamicColor.withBrightness(
    color: Color(0x33000000),
    darkColor: Color(0x66000000),
  ),
  // backgroundBlur: SmartContextMenuBlur.extraStrong,
  itemPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  dividersBetweenItems: true,
  dividerIndent: 52,
);

const _ink = Color(0xFF4A3728);

/// Warm paper in both themes, with a serif font.
const paperStyle = SmartContextMenuStyle(
  surface: SmartContextMenuSurface.standard,
  standardStyle: SmartContextMenuStandardStyle(
    color: Color(0xFFFBF3E4),
    border: BorderSide(color: Color(0x334A3728)),
  ),
  borderRadius: BorderRadius.all(Radius.circular(6)),
  menuShadows: [
    BoxShadow(color: Color(0x404A3728), blurRadius: 18, offset: Offset(0, 8)),
  ],
  backgroundColor: Color(0x404A2E12),
  // backgroundBlur: SmartContextMenuBlur.small,
  titleStyle: TextStyle(fontSize: 17, fontFamily: 'Literata', color: _ink),
  disabledForegroundColor: Color(0x664A3728),
  destructiveColor: Color(0xFFB3261E),
  highlightColor: Color(0x1A4A3728),
  separatorColor: Color(0x1F4A3728),
  separatorThickness: 1,
  dividersBetweenItems: true,
  dividerColor: Color(0x264A3728),
  rowStyle: SmartContextMenuRowStyle(
    titleStyle: TextStyle(fontSize: 12, fontFamily: 'Literata'),
  ),
);

const _glowBorder = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: Color(0x8022D3EE),
    darkColor: Color(0x6622D3EE),
  ),
);

/// A narrow cyan menu with a glow inside and around the panel.
const glowStyle = SmartContextMenuStyle(
  glassStyle: SmartContextMenuGlassStyle(
    color: CupertinoDynamicColor.withBrightness(
      color: Color(0x8CD8FBFF),
      darkColor: Color(0x73102E37),
    ),
    refraction: 1.25,
    edgeHighlight: 0.55,
    border: _glowBorder,
  ),
  standardStyle: SmartContextMenuStandardStyle(
    color: CupertinoDynamicColor.withBrightness(
      color: Color(0xB3ECFEFF),
      darkColor: Color(0x8C06232B),
    ),
    border: _glowBorder,
    blur: SmartContextMenuBlur.extraStrong,
  ),
  borderRadius: BorderRadius.all(Radius.circular(22)),
  menuShadows: [
    BoxShadow(
      color: CupertinoDynamicColor.withBrightness(
        color: Color(0x6022D3EE),
        darkColor: Color(0x7322D3EE),
      ),
      blurRadius: 48,
      spreadRadius: 2,
    ),
  ],
  backgroundColor: CupertinoDynamicColor.withBrightness(
    color: Color(0x330E7490),
    darkColor: Color(0x99020A0F),
  ),
  // backgroundBlur: SmartContextMenuBlur.strong,
  titleStyle: TextStyle(
    fontSize: 17,
    color: CupertinoDynamicColor.withBrightness(
      color: Color(0xFF083344),
      darkColor: Color(0xFFE0FBFF),
    ),
  ),
  defaultIconColor: CupertinoDynamicColor.withBrightness(
    color: Color(0xFF0891B2),
    darkColor: Color(0xFF22D3EE),
  ),
  disabledForegroundColor: CupertinoDynamicColor.withBrightness(
    color: Color(0x66083344),
    darkColor: Color(0x66E0FBFF),
  ),
  destructiveColor: CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE11D48),
    darkColor: Color(0xFFFF6B8A),
  ),
  highlightColor: Color(0x3322D3EE),
  separatorColor: Color(0x2622D3EE),
);

/// Narrow enough for titles without icons.
const glowMenuWidth = 210.0;

const editingRowsAccent = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF5C329C),
  darkColor: Color(0xFFDFC7FF),
);
const editingRowsSectionColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xB3EAF2ED),
  darkColor: Color(0xB3293A33),
);
const editingRowsSelectionColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFE7DDF9),
  darkColor: Color(0xFF533D68),
);

/// Sections for formatting and alignment above the clipboard actions.
const editingRowsStyle = SmartContextMenuStyle(
  glassStyle: SmartContextMenuGlassStyle(
    color: CupertinoDynamicColor.withBrightness(
      color: Color(0xACF3FCF6),
      darkColor: Color(0xB3192D25),
    ),
    edgeHighlight: 0.8,
    border: BorderSide(
      color: CupertinoDynamicColor.withBrightness(
        color: Color(0x78708E7E),
        darkColor: Color(0x8069907E),
      ),
    ),
  ),
  standardStyle: SmartContextMenuStandardStyle(
    color: CupertinoDynamicColor.withBrightness(
      color: Color(0xFFF9FDFA),
      darkColor: Color(0xFF1C2A25),
    ),
    border: BorderSide(
      color: CupertinoDynamicColor.withBrightness(
        color: Color(0xFFD7E3DB),
        darkColor: Color(0xFF40534A),
      ),
    ),
  ),
  borderRadius: BorderRadius.all(Radius.circular(20)),
  menuShadows: [
    BoxShadow(
      color: CupertinoDynamicColor.withBrightness(
        color: Color(0x3018392D),
        darkColor: Color(0x66091611),
      ),
      blurRadius: 22,
      offset: Offset(0, 7),
    ),
  ],
  backgroundColor: CupertinoDynamicColor.withBrightness(
    color: Color(0x26517361),
    darkColor: Color(0x66101715),
  ),
  // backgroundBlur: SmartContextMenuBlur.small,
  titleStyle: TextStyle(
    fontSize: 17,
    color: CupertinoDynamicColor.withBrightness(
      color: Color(0xFF263830),
      darkColor: Color(0xFFEAF4EE),
    ),
  ),
  // The cells paint their own rounded highlights.
  highlightColor: Color(0x00000000),
  rowStyle: SmartContextMenuRowStyle(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    smallItemPadding: EdgeInsets.zero,
    mediumItemPadding: EdgeInsets.zero,
  ),
);

const drawingToolbarSurface = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFFF8FB),
  darkColor: Color(0xFF392632),
);
const drawingToolbarCapsule = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFF2E7EE),
  darkColor: Color(0xFF523743),
);
const drawingToolbarAccent = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF7040AB),
  darkColor: Color(0xFFE0C2FF),
);
const drawingToolbarEditingColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF187564),
  darkColor: Color(0xFFA9E8D1),
);
const drawingToolbarPaint = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFA84924),
  darkColor: Color(0xFFFFB48D),
);
const _drawingToolbarForeground = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF392633),
  darkColor: Color(0xFFFFF0EF),
);
const _drawingToolbarLine = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFDAC7D4),
  darkColor: Color(0xFF634756),
);

/// Capsules in a wide toolbar and an integrated Back row over the shapes.
const drawingToolbarStyle = SmartContextMenuStyle(
  glassStyle: SmartContextMenuGlassStyle(
    color: CupertinoDynamicColor.withBrightness(
      color: Color(0x78FFF1FA),
      darkColor: Color(0x80392632),
    ),
    edgeHighlight: 0.75,
    border: BorderSide(
      color: CupertinoDynamicColor.withBrightness(
        color: Color(0x66956E91),
        darkColor: Color(0x80917991),
      ),
    ),
  ),
  standardStyle: SmartContextMenuStandardStyle(
    color: drawingToolbarSurface,
    border: BorderSide(color: _drawingToolbarLine),
  ),
  borderRadius: BorderRadius.all(Radius.circular(20)),
  menuShadows: [
    BoxShadow(
      color: CupertinoDynamicColor.withBrightness(
        color: Color(0x30432A3B),
        darkColor: Color(0x66210D1B),
      ),
      blurRadius: 26,
      offset: Offset(0, 7),
    ),
  ],
  backgroundColor: CupertinoDynamicColor.withBrightness(
    color: Color(0x2669495E),
    darkColor: Color(0x66301E2A),
  ),
  // backgroundBlur: SmartContextMenuBlur.small,
  titleStyle: TextStyle(fontSize: 14, color: _drawingToolbarForeground),
  defaultIconSize: 16,
  // The tool and shape capsules paint their own highlights.
  highlightColor: Color(0x00000000),
  dividerColor: _drawingToolbarLine,
  dividerIndent: 8,
  dividerEndIndent: 8,
  itemPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
  backButtonStyle: SmartContextMenuBackButtonStyle(
    blur: null,
    foregroundColor: _drawingToolbarForeground,
    highlightColor: CupertinoDynamicColor.withBrightness(
      color: Color(0x1F7040AB),
      darkColor: Color(0x1FE0C2FF),
    ),
    titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  ),
  rowStyle: SmartContextMenuRowStyle(
    padding: EdgeInsets.all(4),
    smallItemPadding: EdgeInsets.zero,
    mediumItemPadding: EdgeInsets.zero,
  ),
);
