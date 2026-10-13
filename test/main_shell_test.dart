import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transhelf/main.dart';

void main() {
  testWidgets('main navigation and language setting work', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(TranshelfApp(preferences: preferences));

    expect(find.byKey(const ValueKey('view.translate')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav.translate')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('nav.shelf')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const ValueKey('view.shelf')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('nav.settings')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const ValueKey('view.settings')), findsOneWidget);
    await tester.tap(find.byKey(const Key('language_setting')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language_option.en')));
    await tester.pumpAndSettle();

    // These assertions intentionally verify localized output, not element identity.
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Translate'), findsWidgets);
    expect(preferences.getString('app_locale'), 'en');

    await tester.tap(find.byKey(const Key('language_setting')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language_option.zh')));
    await tester.pumpAndSettle();
    expect(find.text('設定'), findsWidgets);
    expect(preferences.getString('app_locale'), 'zh');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(TranshelfApp(preferences: preferences));
    expect(find.byKey(const ValueKey('view.translate')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
  });
}
