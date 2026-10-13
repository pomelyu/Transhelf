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

    expect(find.text('翻譯結果會顯示於此'), findsOneWidget);
    await tester.tap(find.text('文章').last);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('還沒有文章'), findsOneWidget);
    await tester.tap(find.text('設定').last);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('language_setting')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Translate'), findsWidgets);
    expect(preferences.getString('app_locale'), 'en');

    await tester.tap(find.byKey(const Key('language_setting')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('繁體中文').last);
    await tester.pumpAndSettle();
    expect(find.text('設定'), findsWidgets);
    expect(preferences.getString('app_locale'), 'zh');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(TranshelfApp(preferences: preferences));
    expect(find.text('翻譯結果會顯示於此'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
  });
}
