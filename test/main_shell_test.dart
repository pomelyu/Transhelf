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

  testWidgets('Gemini can be selected and its API key is saved separately', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(TranshelfApp(preferences: preferences));

    await tester.tap(find.byKey(const ValueKey('engine_dropdown')));
    await tester.pumpAndSettle();
    expect(find.text('Gemini'), findsOneWidget);
    expect(find.text('ChatGPT'), findsOneWidget);
    await tester.tap(find.text('Gemini'));
    await tester.pumpAndSettle();
    expect(find.text('Gemini'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav.settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('google_settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('google_api_key')), findsOneWidget);
    expect(find.byKey(const ValueKey('save_google_api_key')), findsNothing);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('google_api_key')))
          .enabled,
      isFalse,
    );
    await tester.tap(find.byKey(const ValueKey('edit_google_api_key')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('google_api_key')))
          .enabled,
      isTrue,
    );
    expect(find.byKey(const ValueKey('save_google_api_key')), findsOneWidget);
    expect(find.text('Google Cloud 專案 ID'), findsNothing);
    expect(find.text('OAuth 存取權杖'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('service_tab_1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('gemini_api_key')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('gemini_model_selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gemini 3.6 Flash'));
    await tester.pumpAndSettle();
    expect(preferences.getString('gemini_model'), 'gemini-3.6-flash');
    await tester.tap(find.byKey(const ValueKey('edit_gemini_api_key')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('gemini_api_key')),
      'gemini-test-key',
    );
    await tester.tap(find.byKey(const ValueKey('save_gemini_api_key')));
    await tester.pumpAndSettle();
    expect(preferences.getString('gemini_api_key'), 'gemini-test-key');

    await tester.tap(find.byKey(const ValueKey('service_tab_2')));
    await tester.pumpAndSettle();
    expect(find.text('即將推出'), findsOneWidget);
  });
}
