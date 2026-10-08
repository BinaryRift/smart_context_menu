import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  group('simple', () {
    test('keeps the given fields', () {
      void onTap() {}
      const leading = SizedBox();
      const trailing = SizedBox();
      const titleStyle = TextStyle(fontSize: 20);
      const metadata = SmartContextMenuPagingMetadata(page: 2);
      final item = SmartContextMenuItem.simple(
        title: 'Edit',
        titleStyle: titleStyle,
        leading: leading,
        trailing: trailing,
        isDestructive: true,
        tintColor: const Color(0xFF00FF00),
        isDisabled: true,
        closeOnTap: false,
        onTap: onTap,
        childrenGap: 4,
        pagingMetadata: metadata,
      );

      expect(item.title, 'Edit');
      expect(item.titleStyle, titleStyle);
      expect(item.leading, same(leading));
      expect(item.trailing, same(trailing));
      expect(item.isDestructive, isTrue);
      expect(item.tintColor, const Color(0xFF00FF00));
      expect(item.isDisabled, isTrue);
      expect(item.closeOnTap, isFalse);
      expect(item.onTap, onTap);
      expect(item.childrenGap, 4);
      expect(item.pagingMetadata, metadata);
    });

    test('has defaults of a plain action', () {
      final item = SmartContextMenuItem.simple(title: 'Edit');

      expect(item.isDestructive, isFalse);
      expect(item.isDisabled, isFalse);
      expect(item.isSeparator, isFalse);
      expect(item.closeOnTap, isTrue);
      expect(item.showTransitionIcon, isFalse);
      expect(item.isInternalInteracted, isFalse);
    });
  });

  test('submenu keeps its children', () {
    final children = [SmartContextMenuItem.simple(title: 'Child')];
    final item = SmartContextMenuItem.submenu(
      title: 'More',
      children: children,
    );

    expect(item.children, same(children));
    expect(item.asyncChildren, isNull);
    expect(item.asyncPagingChildren, isNull);
    expect(item.showTransitionIcon, isTrue);
    expect(item.isInternalInteracted, isTrue);
  });

  test('asyncSubmenu keeps its loader and timeout', () {
    Future<List<SmartContextMenuItem>> loader() async => [];
    final item = SmartContextMenuItem.asyncSubmenu(
      title: 'More',
      asyncChildren: loader,
      timeout: const Duration(seconds: 3),
    );

    expect(item.asyncChildren, loader);
    expect(item.loadingTimeout, const Duration(seconds: 3));
    expect(item.children, isNull);
    expect(item.asyncPagingChildren, isNull);
    expect(item.showTransitionIcon, isTrue);
    expect(item.isInternalInteracted, isTrue);
  });

  test('pagingSubmenu keeps its loader, timeout and first page metadata', () {
    Future<List<SmartContextMenuItem>> loader(
      SmartContextMenuPagingMetadata metadata,
    ) async => [];
    const metadata = SmartContextMenuPagingMetadata(limit: 10);
    final item = SmartContextMenuItem.pagingSubmenu(
      title: 'Pages',
      asyncPagingChildren: loader,
      initialMetadata: metadata,
      timeout: const Duration(seconds: 3),
    );

    expect(item.asyncPagingChildren, loader);
    expect(item.loadingTimeout, const Duration(seconds: 3));
    expect(item.pagingMetadata, metadata);
    expect(item.children, isNull);
    expect(item.asyncChildren, isNull);
    expect(item.showTransitionIcon, isTrue);
    expect(item.isInternalInteracted, isTrue);
  });

  group('async', () {
    Future<SmartContextMenuItem> loader() async =>
        SmartContextMenuItem.simple(title: 'Loaded');

    test('keeps the loader and the placeholder fields', () {
      const leading = SizedBox();
      const titleStyle = TextStyle(fontSize: 20);
      Widget builder(BuildContext context, SmartContextMenuItemState state) =>
          const SizedBox();
      final item = SmartContextMenuItem.async(
        asyncItem: loader,
        timeout: const Duration(seconds: 3),
        leading: leading,
        loadingTitle: 'Checking',
        titleStyle: titleStyle,
        loadingBuilder: builder,
        errorBuilder: builder,
        childrenGap: 4,
      );

      expect(item.asyncItem, loader);
      expect(item.loadingTimeout, const Duration(seconds: 3));
      expect(item.leading, same(leading));
      expect(item.title, 'Checking');
      expect(item.titleStyle, titleStyle);
      expect(item.loadingBuilder, builder);
      expect(item.errorBuilder, builder);
      expect(item.childrenGap, 4);
    });

    test('stays open on tap and uses the default timeout', () {
      final item = SmartContextMenuItem.async(asyncItem: loader);

      expect(item.loadingTimeout, SmartContextMenuDefaults.loadingTimeout);
      expect(item.closeOnTap, isFalse);
      expect(item.showTransitionIcon, isFalse);
      expect(item.isInternalInteracted, isTrue);
    });
  });

  group('listenable', () {
    final listenable = ChangeNotifier();
    SmartContextMenuItem? builder() => null;

    tearDownAll(listenable.dispose);

    test('keeps the listenable, the builder and the placeholder fields', () {
      const leading = SizedBox();
      const titleStyle = TextStyle(fontSize: 20);
      Widget loadingBuilder(
        BuildContext context,
        SmartContextMenuItemState state,
      ) => const SizedBox();
      final item = SmartContextMenuItem.listenable(
        listenable: listenable,
        builder: builder,
        leading: leading,
        loadingTitle: 'Checking',
        titleStyle: titleStyle,
        loadingBuilder: loadingBuilder,
        childrenGap: 4,
      );

      expect(item.listenable, same(listenable));
      expect(item.listenableBuilder, builder);
      expect(item.leading, same(leading));
      expect(item.title, 'Checking');
      expect(item.titleStyle, titleStyle);
      expect(item.loadingBuilder, loadingBuilder);
      expect(item.childrenGap, 4);
    });

    test('leaves taps to the built item', () {
      final item = SmartContextMenuItem.listenable(
        listenable: listenable,
        builder: builder,
      );

      expect(item.closeOnTap, isFalse);
      expect(item.onTap, isNull);
      expect(item.asyncItem, isNull);
      expect(item.loadingTimeout, isNull);
      expect(item.errorBuilder, isNull);
      expect(item.showTransitionIcon, isFalse);
      expect(item.isInternalInteracted, isFalse);
    });
  });

  test('async submenus use the default timeout', () {
    final async = SmartContextMenuItem.asyncSubmenu(
      asyncChildren: () async => [],
    );
    final paging = SmartContextMenuItem.pagingSubmenu(
      asyncPagingChildren: (_) async => [],
      initialMetadata: const SmartContextMenuPagingMetadata(),
    );

    expect(async.loadingTimeout, SmartContextMenuDefaults.loadingTimeout);
    expect(paging.loadingTimeout, SmartContextMenuDefaults.loadingTimeout);
  });

  group('separator', () {
    test('is a separator without actions', () {
      final item = SmartContextMenuItem.separator();

      expect(item.isSeparator, isTrue);
      expect(item.closeOnTap, isFalse);
      expect(item.onTap, isNull);
      expect(item.customBuilder, isNull);
      expect(item.isInternalInteracted, isFalse);
    });

    test('builds the given child', () {
      const child = Text('Section');
      const metadata = SmartContextMenuPagingMetadata(page: 2);
      final item = SmartContextMenuItem.separator(
        child: child,
        pagingMetadata: metadata,
      );

      expect(
        item.customBuilder!(
          _FakeContext(),
          const SmartContextMenuItemState(
            isPressed: false,
            isDisabled: false,
            isDestructive: false,
            foregroundColor: Color(0xFF000000),
          ),
        ),
        same(child),
      );
      expect(item.pagingMetadata, metadata);
    });
  });

  group('id', () {
    test('is generated unique for each item', () {
      final ids = {
        SmartContextMenuItem.simple(title: 'Edit').id,
        SmartContextMenuItem.simple(title: 'Edit').id,
        SmartContextMenuItem.submenu(children: []).id,
        SmartContextMenuItem.asyncSubmenu(asyncChildren: () async => []).id,
        SmartContextMenuItem.pagingSubmenu(
          asyncPagingChildren: (_) async => [],
          initialMetadata: const SmartContextMenuPagingMetadata(),
        ).id,
        SmartContextMenuItem.async(
          asyncItem: () async => SmartContextMenuItem.simple(),
        ).id,
        SmartContextMenuItem.listenable(
          listenable: ChangeNotifier(),
          builder: () => null,
        ).id,
        SmartContextMenuItem.separator().id,
      };

      expect(ids, hasLength(8));
    });

    test('keeps the given value', () {
      final items = [
        SmartContextMenuItem.simple(id: 'a'),
        SmartContextMenuItem.submenu(id: 'a', children: []),
        SmartContextMenuItem.asyncSubmenu(
          id: 'a',
          asyncChildren: () async => [],
        ),
        SmartContextMenuItem.pagingSubmenu(
          id: 'a',
          asyncPagingChildren: (_) async => [],
          initialMetadata: const SmartContextMenuPagingMetadata(),
        ),
        SmartContextMenuItem.async(
          id: 'a',
          asyncItem: () async => SmartContextMenuItem.simple(),
        ),
        SmartContextMenuItem.listenable(
          id: 'a',
          listenable: ChangeNotifier(),
          builder: () => null,
        ),
        SmartContextMenuItem.separator(id: 'a'),
      ];

      for (final item in items) {
        expect(item.id, 'a');
      }
    });
  });

  group('padding', () {
    test('keeps the given value', () {
      const padding = EdgeInsets.all(2);
      final items = [
        SmartContextMenuItem.simple(padding: padding),
        SmartContextMenuItem.submenu(padding: padding, children: []),
        SmartContextMenuItem.asyncSubmenu(
          padding: padding,
          asyncChildren: () async => [],
        ),
        SmartContextMenuItem.pagingSubmenu(
          padding: padding,
          asyncPagingChildren: (_) async => [],
          initialMetadata: const SmartContextMenuPagingMetadata(),
        ),
        SmartContextMenuItem.async(
          padding: padding,
          asyncItem: () async => SmartContextMenuItem.simple(),
        ),
        SmartContextMenuItem.listenable(
          padding: padding,
          listenable: ChangeNotifier(),
          builder: () => null,
        ),
      ];

      for (final item in items) {
        expect(item.padding, padding);
      }
    });

    // The style padding is applied when the item is shown.
    test('is null when not given', () {
      expect(SmartContextMenuItem.simple().padding, isNull);
    });
  });
}

final class _FakeContext extends Fake implements BuildContext {}
