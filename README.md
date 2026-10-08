# smart_context_menu

An iOS-style context menu for Flutter with smart positioning, fluid animations,
drag-to-select and rich submenus.

<!-- GIF: long press opens the menu, an item is selected -->

## Features

- **Long press to open** with a lifted preview of the pressed widget; tap the preview
  to run the widget's main action.
- **Smart positioning**: the pressed widget stays in place whenever there is room for the menu;
  very tall widgets can be scrolled, and long menus scroll inside themselves.
- **Drag-to-select**: slide a finger across the items and release on the one you want.
- **Custom slivers above the widget**, for example a reactions bar above a message,
  animated with the menu and optionally pinned to the top.
- **Submenus**: static, loaded asynchronously or paginated, with a back item and swipe back.
- **Lazy lists**: items are built only when they scroll into view, so long menus stay fast.
- **Async items** that show a loading state and a retry item on failure, with optional custom views.
- **Light and dark themes** out of the box.
- **Customizable**: size, colors, text, icons, blur, decoration, labels, dividers
  and custom item content.
- **Programmatic control**: open and close the menu from code with `SmartContextMenuController`,
  or turn off the long press and open the menu only from code.

## Getting started

```sh
flutter pub add smart_context_menu
```

```dart
import 'package:smart_context_menu/smart_context_menu.dart';
```

## Usage

Wrap a widget with `SmartContextMenu` and pass the items. The menu opens on long press.

```dart
SmartContextMenu(
  items: [
    SmartContextMenuItem.simple(
      title: 'Copy',
      leading: const Icon(CupertinoIcons.doc_on_doc),
      onTap: () => copy(),
    ),
    SmartContextMenuItem.simple(
      title: 'Delete',
      leading: const Icon(CupertinoIcons.delete),
      isDestructive: true,
      onTap: () => delete(),
    ),
  ],
  child: const MessageBubble(),
)
```

Only the long press is taken from the child: its taps, drags and other gestures keep working.

The preview above the open menu is a snapshot of the child, so its own buttons do not
work there. To run the main action of the child when the preview is tapped, for example
to open a message, pass `onPreviewTap`. The menu starts closing first, as with an item:

```dart
SmartContextMenu(
  onPreviewTap: () => openMessage(message),
  items: items,
  child: MessageBubble(message),
)
```

### Header slivers

<!-- GIF: reactions bar above a message -->

To show your own content above the widget while the menu is open, pass `headerSliversBuilder`.
It returns a list of slivers, which fade in and out with the menu and move with the widget
when it is dragged or the menu is stretched. The builder gets `SmartContextMenuHeaderDetails`:

- `alignment` tells how the widget and the menu are aligned horizontally. The slivers have
  the same horizontal padding as the widget, so `Align(alignment: header.alignment)` puts
  your content at the edge of the widget.
- `animation` runs from 0 to 1 as the menu opens and back as it closes, to animate
  your content with the menu.
- `close()` closes the menu. It completes halfway through the closing, as an item does,
  so the result of the action is seen as the menu closes.

A tap on your widgets in the slivers keeps the menu open; a tap on empty space next to them
closes it, as a tap anywhere outside the menu does.

```dart
SmartContextMenu(
  headerSliversBuilder: (context, header) => [
    SliverToBoxAdapter(
      child: Align(
        alignment: header.alignment,
        child: ReactionsBar(
          onSelected: (reaction) async {
            await header.close();
            react(message, reaction);
          },
        ),
      ),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: 8)),
  ],
  items: items,
  child: MessageBubble(message),
)
```

For example, to scale the bar in from the edge of the widget, wrap it with a transition
driven by `header.animation`. Use `drive` rather than `CurvedAnimation`: the builder runs
on every rebuild, and a `CurvedAnimation` created there is never disposed.

```dart
ScaleTransition(
  scale: header.animation.drive(CurveTween(curve: Curves.easeOutBack)),
  // Grows from the bottom edge, next to the widget.
  alignment: Alignment(header.alignment.x, 1),
  child: ReactionsBar(onSelected: react),
)
```

The fade stays on top of your animation; set `fadeHeaderSlivers: false` to animate
the slivers only your way.

The slivers are direct children of the scroll view of the menu, so a `PinnedHeaderSliver`
stays at the top, right below the status bar, while a tall widget and the menu scroll
under it. It covers them there, so keep it small:

```dart
headerSliversBuilder: (context, header) => [
  PinnedHeaderSliver(
    child: Align(
      alignment: header.alignment,
      child: ReactionsBar(onSelected: react),
    ),
  ),
],
```

### Positioning

The menu opens right below the pressed widget, and the widget stays exactly where it was.
It moves up only when the widget and the menu together do not fit below it, and only as far
as needed. Horizontally, the menu lines up with the widget's left or right edge, or centers
under it, depending on where the widget is on the screen. [Header slivers](#header-slivers)
are shown right above the widget; if there is no room for them, the widget and the menu
move down. If they do not fit on the screen together, the widget and the menu take priority:
the slivers scroll out at the top.

- **Shorter menus.** When the menu gets shorter, for example after returning from a submenu,
  it stays where it is, so it stays under the finger: the parent menu starts where the back
  item was. Set `moveBackDown: true` in `SmartContextMenuConfig` to move the widget back down
  instead; it never goes below its place.

- **Tall widgets.** If the widget and the menu do not fit on the screen even after moving,
  they can be scrolled together, so every part of the widget and the menu stays reachable.
- **Long menus.** The menu is never taller than a part of the screen set by
  `SmartContextMenuConfig.menuHeightFactor` (60% by default); items that do not fit scroll
  inside the menu and are built only when they scroll into view.

`screenPadding` and `menuGap` in `SmartContextMenuConfig` set the distance to the screen
edges and between the widget and the menu.

### Item types

Create items with the factory that matches what the item does:

| Factory | What it does |
| --- | --- |
| `SmartContextMenuItem.simple` | Runs `onTap`. |
| `SmartContextMenuItem.submenu` | Opens a submenu with `children`. |
| `SmartContextMenuItem.asyncSubmenu` | Opens a submenu and loads its items. |
| `SmartContextMenuItem.pagingSubmenu` | Opens a submenu and loads its items page by page. |
| `SmartContextMenuItem.async` | Shows a placeholder and replaces it with a loaded item. |
| `SmartContextMenuItem.separator` | Separates groups of items. |

#### Submenu

<!-- GIF: submenu, back item and swipe back -->

```dart
SmartContextMenuItem.submenu(
  title: 'Move to',
  leading: const Icon(CupertinoIcons.folder),
  children: [
    SmartContextMenuItem.simple(title: 'Documents', onTap: () => move('docs')),
    SmartContextMenuItem.simple(title: 'Archive', onTap: () => move('archive')),
  ],
)
```

Tap the back item at the top of the submenu or swipe right to return to the parent menu.
The submenu follows the finger and slides back in place if the swipe is short.
To turn the swipe off, set `enableSwipeBack: false` in `SmartContextMenuConfig`.

#### Async submenu

The items are loaded when the submenu opens and cached until the menu closes.
If loading fails, the submenu shows a retry item.

```dart
SmartContextMenuItem.asyncSubmenu(
  title: 'Recent files',
  leading: const Icon(CupertinoIcons.clock),
  asyncChildren: () async {
    final files = await repository.recentFiles();
    return [
      for (final file in files)
        SmartContextMenuItem.simple(title: file.name, onTap: () => open(file)),
    ];
  },
)
```

#### Paginated submenu

<!-- GIF: paginated submenu loads the next page on scroll -->

The first page is loaded with `initialMetadata`. The last item of each page carries
the metadata of the next page in `pagingMetadata`; the next page is loaded when the
user scrolls to the end. Leave it `null` on the last page.

```dart
SmartContextMenuItem.pagingSubmenu(
  title: 'Contacts',
  initialMetadata: const SmartContextMenuPagingMetadata(limit: 20),
  asyncPagingChildren: (metadata) async {
    final page = await api.contacts(page: metadata.page, limit: metadata.limit);
    return [
      for (final (index, contact) in page.items.indexed)
        SmartContextMenuItem.simple(
          title: contact.name,
          pagingMetadata: index == page.items.length - 1 && page.hasMore
              ? metadata.copyWith(page: metadata.page + 1)
              : null,
        ),
    ];
  },
)
```

`SmartContextMenuPagingMetadata` also has `nextCursor` for cursor-based APIs and
`extra` for custom parameters.

#### Async item

The placeholder loads its item as soon as it appears. Loading and error views can be
replaced; if a builder is not set, the default view is used.

```dart
SmartContextMenuItem.async(
  loadingTitle: 'Checking access',
  asyncItem: () async {
    final canEdit = await permissions.canEdit();
    return SmartContextMenuItem.simple(
      title: 'Edit',
      isDisabled: !canEdit,
      onTap: () => edit(),
    );
  },
  errorBuilder: (context, state) => Text(
    'Could not check access. Tap to retry',
    style: TextStyle(color: state.foregroundColor),
  ),
)
```

#### Separator

A separator splits the items into groups. It has no actions and no press highlight,
and drag-to-select passes over it. By default it is a band set by `separatorHeight`
and `separatorColor` in the style; `child` replaces it, for example with a section title.

Separators at the start or the end of a menu are not shown, and several separators
in a row show as one. So a menu whose items depend on the user or the content
needs no extra checks:

```dart
[
  if (canReply)
    SmartContextMenuItem.simple(title: 'Reply', onTap: () => reply()),
  SmartContextMenuItem.simple(title: 'Copy', onTap: () => copy()),
  if (isAdmin) SmartContextMenuItem.simple(title: 'Pin', onTap: () => pin()),
  SmartContextMenuItem.separator(),
  // Without Delete, the separator above is not shown.
  if (canDelete)
    SmartContextMenuItem.simple(
      title: 'Delete',
      isDestructive: true,
      onTap: () => delete(),
    ),
]
```

For a thin line instead of a band, set a small `separatorHeight` and the
`dividerColor` as `separatorColor`. To draw lines between all items, see
[Dividers](#dividers).

### Opening from code

Pass a `SmartContextMenuController` to open and close the menu from code.
To open the menu only from code, set the activation mode to `manual`.

```dart
final controller = SmartContextMenuController();

SmartContextMenu(
  controller: controller,
  config: const SmartContextMenuConfig(
    activationMode: SmartContextMenuActivationMode.manual,
  ),
  items: items,
  child: child,
);

IconButton(
  icon: const Icon(CupertinoIcons.ellipsis),
  onPressed: controller.open,
);
```

The controller notifies its listeners when the menu opens or closes, see `isOpen`.
Dispose it when it is no longer needed.

### Customization

All settings live in `SmartContextMenuConfig`, and the appearance in its `style`.
Create the config once and reuse it to keep the menus in the app consistent.

```dart
const menuConfig = SmartContextMenuConfig(
  menuWidth: 250,
  enableHaptics: false,
  style: SmartContextMenuStyle(
    menuBlur: SmartContextMenuBlur.small,
    backgroundBlur: SmartContextMenuBlur(10),
    borderRadius: BorderRadius.all(Radius.circular(20)),
    menuShadows: [BoxShadow(color: Color(0x33000000), blurRadius: 20)],
  ),
);
```

`menuShadows` replaces the default shadows under the menu; pass an empty list to remove them.

`SmartContextMenuStyle` also sets the text, colors, icons and spacing of items, so the menu
can match the app theme:

```dart
const menuStyle = SmartContextMenuStyle(
  titleStyle: TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 17,
    color: Color(0xFFFFFFFF),
  ),
  disabledForegroundColor: Color(0x99FFFFFF),
  destructiveColor: Color(0xFFFF453A),
  highlightColor: Color(0x1FFFFFFF),
  dividerColor: Color(0x999E9E9E),
  backButtonColor: Color(0xFF0A84FF),
  submenuIcon: Icons.arrow_forward_ios,
  backIcon: Icons.arrow_back_ios_new,
  itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  itemChildrenGap: 10,
);
```

The color of `titleStyle` is used for enabled items that are not destructive.
Disabled and destructive items use `disabledForegroundColor` and `destructiveColor`.
Disabled items have no background unless `disabledBackgroundColor` is set.
A pressed item is highlighted with a translucent `titleStyle` color; `highlightColor`
replaces it. Tinted and destructive items keep their own pressed tint.
Icons in `leading` and `trailing` take the title color unless they set their own.
The back item of a submenu merges `backButtonTitleStyle` (bold by default) over
`titleStyle`; `backButtonColor` sets the color of its title and icon.
Titles take up to `titleMaxLines` lines (2 by default) and are truncated with an ellipsis.
`itemPadding` and `itemChildrenGap` set the padding of items and the gap between
their icons and title.

**Settings of an item take precedence over the style.** The style sets the look of
all items, and an item changes it only for itself:

```dart
// The style: padding and text of all items.
const style = SmartContextMenuStyle(
  itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  titleStyle: TextStyle(fontSize: 17),
);

// This item uses its own padding and text style instead.
SmartContextMenuItem.simple(
  title: 'Open in new window',
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  titleStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  onTap: () => openInNewWindow(),
)
```

The same goes for `childrenGap` over `itemChildrenGap`, and `tintColor` over
`destructiveColor`.

To give one item its own color, set its `tintColor`. The item is tinted like a destructive
one: the title and icons take the color, and the background a translucent shade of it.
A disabled tinted item keeps only the dimmed color of the title and icons.
`tintColor` takes precedence over `destructiveColor` and the `titleStyle` color.

```dart
SmartContextMenuItem.simple(
  title: 'Approve',
  leading: const Icon(CupertinoIcons.checkmark),
  tintColor: CupertinoColors.systemGreen,
  onTap: () => approve(),
)
```

Colors may be `CupertinoDynamicColor`s: they follow the light and dark theme.
A plain `Color` is used as is in both themes. The default values are available
in `SmartContextMenuDefaults`.

To change a few settings of a shared config for one menu, use `copyWith`.
`SmartContextMenuStyle` has it too:

```dart
SmartContextMenu(
  config: menuConfig.copyWith(
    activationMode: SmartContextMenuActivationMode.manual,
    style: menuConfig.style.copyWith(menuBlur: SmartContextMenuBlur.small),
  ),
  controller: controller,
  items: items,
  child: child,
)
```

#### Dividers

Dividers are thin lines between items, as in iOS. They are off by default; set
`dividersBetweenItems: true` in the style to draw a line between every two items.
No line is drawn next to a separator, so groups stay split by separators only.
The style also sets the look of the lines: `dividerColor`, `dividerThickness`, and
the space before and after them with `dividerIndent` and `dividerEndIndent`.

```dart
const style = SmartContextMenuStyle(
  dividersBetweenItems: true,
  dividerThickness: 1,
  dividerIndent: 52,
);
```

To split items into groups, use a [separator](#separator).

#### Custom item content

`customBuilder` replaces the content of an item. The item padding and press highlight
are kept, and taps work as usual. Interactive widgets inside, such as
buttons, handle their own taps: the item is not triggered over them. The builder
receives the item state, including `foregroundColor`: the color of the title and icons
for the current state and theme.

```dart
SmartContextMenuItem.simple(
  onTap: () => reply(),
  customBuilder: (context, state) => Row(
    children: [
      Icon(CupertinoIcons.reply, color: state.foregroundColor),
      const SizedBox(width: 12),
      Text('Reply', style: TextStyle(color: state.foregroundColor)),
    ],
  ),
)
```

### Localization

The menu shows a few strings itself: the back item, the retry item and the loading
placeholder. Override them with `SmartContextMenuLabels`:

```dart
SmartContextMenuConfig(
  labels: SmartContextMenuLabels(
    back: l10n.back,
    retry: l10n.retry,
    loading: l10n.loading,
  ),
)
```

## Additional information

Found a bug or have a feature request? Open an issue on
[GitHub](https://github.com/BinaryRift/smart_context_menu/issues).

Licensed under the [MIT License](LICENSE).
