import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transhelf/main.dart';
import 'package:transhelf/services/chatgpt_translation_service.dart';

void main() {
  testWidgets('ChatGPT translates with the selected preset and model', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    Uri? receivedUri;
    String? receivedKey;
    Map<String, Object?>? receivedBody;
    final service = ChatGPTTranslationService(
      post: (uri, key, body) async {
        receivedUri = uri;
        receivedKey = key;
        receivedBody = body;
        return (
          200,
          jsonEncode({
            'output': [
              {
                'type': 'message',
                'role': 'assistant',
                'content': [
                  {'type': 'output_text', 'text': '譯文。'},
                ],
              },
            ],
          }),
        );
      },
    );
    await tester.pumpWidget(
      TranshelfApp(
        preferences: preferences,
        initialChatGPTApiKey: 'openai-key',
        initialChatGPTModel: 'gpt-4.1-mini',
        chatGPTTranslationService: service,
      ),
    );
    await tester.pumpAndSettle();
    const source = 'A sentence to translate.';
    await tester.enterText(
      find.byKey(const ValueKey('translate_input')),
      source,
    );
    FocusScope.of(tester.element(find.byKey(const ValueKey('translate_input'))))
        .unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('engine_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ChatGPT'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('gemini_prompt_preview')));
    await tester.pumpAndSettle();
    final preview = tester.widget<SelectableText>(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(SelectableText),
      ),
    );
    expect(preview.data, contains('...'));
    expect(preview.data, isNot(contains(source)));
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('translate_button')));
    await tester.pumpAndSettle();

    expect(receivedUri, Uri.https('api.openai.com', '/v1/responses'));
    expect(receivedKey, 'openai-key');
    expect(receivedBody?['model'], 'gpt-4.1-mini');
    expect(receivedBody?['store'], false);
    expect(receivedBody?['input'], contains(source));
    expect(find.text('譯文。'), findsOneWidget);
    expect(find.byKey(const ValueKey('save_article_button')), findsOneWidget);
  });
}
