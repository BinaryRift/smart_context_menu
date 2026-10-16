import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu_example/core/data/demo_loader.dart';
import 'package:smart_context_menu_example/core/ui/reactions_bar.dart';
import 'package:smart_context_menu_example/main.dart';
import 'package:smart_context_menu_example/pages/chat/domain/demo_chat.dart';
import 'package:smart_context_menu_example/pages/detail/ui/detail_page.dart';
import 'package:smart_context_menu_example/resources/assets/app_images.dart';

import '../helpers/menu_tester.dart';

void main() {
  final myMessage = find.text('I am in. I will bring snacks for everyone');

  Finder photo(AppImage image) => find.byWidgetPredicate(
    (widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == image.path,
  );

  Future<void> openChat(WidgetTester tester) async {
    await tester.pumpPhoneApp();
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
  }

  Future<void> doubleTapAt(WidgetTester tester, Offset position) async {
    await tester.tapAt(position);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(position);
    await tester.settleMenu();
  }

  testWidgets('a double tap left of a message of the user opens its menu', (
    tester,
  ) async {
    await openChat(tester);

    final message = tester.getRect(myMessage);
    await doubleTapAt(tester, Offset(20, message.center.dy));

    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    // Lets the Seen by item finish loading.
    await tester.pump(demoLoadDelay);
  });

  testWidgets('a double tap right of an incoming photo opens its menu', (
    tester,
  ) async {
    await openChat(tester);

    final photoRect = tester.getRect(photo(AppImages.waterfall));
    final screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    await doubleTapAt(tester, Offset(screenWidth - 20, photoRect.center.dy));

    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('a message opens its menu with the reactions above it', (
    tester,
  ) async {
    await openChat(tester);

    await tester.openMenu(myMessage);

    expect(find.byType(ReactionsBar), findsOneWidget);
    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    // Lets the Seen by item finish loading.
    await tester.pump(demoLoadDelay);
  });

  testWidgets('a reaction closes the menu and shows under the message', (
    tester,
  ) async {
    await openChat(tester);
    await tester.openMenu(myMessage);

    await tester.tap(find.text('❤️'));
    await tester.pump();
    expect(find.text('Selected reaction ❤️'), findsOneWidget);
    await tester.settleMenu();

    expect(find.byType(ReactionsBar), findsNothing);
    expect(find.text('❤️ 1'), findsOneWidget);
    final notice = tester.getRect(find.text('Selected reaction ❤️'));
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(notice.bottom, greaterThan(screenHeight * 0.7));
    expect(notice.bottom, lessThan(screenHeight - 80));
  });

  testWidgets('Seen by turns into a submenu once loaded', (tester) async {
    await openChat(tester);
    await tester.openMenu(myMessage);
    expect(find.text('Seen by'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.eye), findsOneWidget);

    await tester.pump(demoLoadDelay);
    await tester.settleMenu();
    expect(find.text('${readers.length}'), findsOneWidget);
    await tester.tap(find.text('Seen by'));
    await tester.settleMenu();

    expect(find.text(readers.last), findsOneWidget);
  });

  testWidgets('Pin pins the message without closing the menu', (tester) async {
    await openChat(tester);
    await tester.openMenu(myMessage);

    await tester.tap(find.text('Pin'));
    await tester.pump();

    expect(find.text('Unpin'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.pin_fill), findsOneWidget);
    // Lets the Seen by item finish loading.
    await tester.pump(demoLoadDelay);
  });

  testWidgets('Reactions lists the people who reacted', (tester) async {
    await openChat(tester);
    final lake = photo(AppImages.lake);
    await tester.dragUntilVisible(
      lake,
      find.byType(ListView),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();
    await tester.openMenu(lake);

    expect(find.text('240'), findsOneWidget);
    await tester.tap(find.text('Reactions'));
    await tester.pump(demoLoadDelay);
    await tester.settleMenu();

    expect(find.text(personName(0)), findsOneWidget);
    await tester.tap(find.text(personName(0)));
    await tester.settleMenu();
    expect(find.text('${personName(0)} reacted 👍'), findsOneWidget);
  });

  testWidgets('a tap on a photo opens it', (tester) async {
    await openChat(tester);

    await tester.tap(photo(AppImages.waterfall));
    await tester.pumpAndSettle();

    expect(find.byType(DetailPage), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets('a tap on the preview of a photo opens it', (tester) async {
    await openChat(tester);
    await tester.openMenu(photo(AppImages.waterfall));
    // The route ignores pointers until its transition ends.
    await tester.settleMenu();

    // The photo is a RawImage too; the preview is above the page.
    await tester.tap(find.byType(RawImage).last);
    await tester.settleMenu();
    await tester.pumpAndSettle();

    expect(find.byType(DetailPage), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets('on a tablet the chat is not wider than 640', (tester) async {
    tester.view.physicalSize = const Size(2048, 2732);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ExampleApp());
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(ListView)).width, 640);
  });
}
