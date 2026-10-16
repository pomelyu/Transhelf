import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transhelf/main.dart';
import 'package:transhelf/models/translation_preset.dart';
import 'package:transhelf/services/gemini_translation_service.dart';
import 'package:transhelf/services/preset_store.dart';

void main() {
  testWidgets('Gemini receives the selected prompt with actual article text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const source = 'A useful sentence for translation.';
    final library = PresetLibrarySnapshot(
      presets: [
        TranslationPreset.fallback,
        const TranslationPreset(
          id: 'custom',
          name: 'Custom',
          prompt: r'Translate from ${source} to ${target}.',
          glossary: [
            PresetGlossaryEntry(id: 'term', source: 'useful', target: '有用的'),
          ],
        ),
      ],
      defaultPresetId: 'custom',
    );
    SharedPreferences.setMockInitialValues({
      PresetStore.storageKey: jsonEncode(library.toJson()),
    });
    final preferences = await SharedPreferences.getInstance();
    String? receivedPrompt;
    String? receivedApiKey;
    Uri? receivedUri;
    final service = GeminiTranslationService(
      post: (uri, apiKey, body) async {
        receivedUri = uri;
        receivedApiKey = apiKey;
        final contents = body['contents']! as List<dynamic>;
        final parts =
            (contents.single as Map<String, dynamic>)['parts']!
                as List<dynamic>;
        receivedPrompt =
            (parts.single as Map<String, dynamic>)['text'] as String;
        return (
          200,
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': '有用的句子。'},
                  ],
                },
              },
            ],
          }),
        );
      },
    );

    await tester.pumpWidget(
      TranshelfApp(
        preferences: preferences,
        initialGeminiApiKey: 'gemini-key',
        initialGeminiModel: 'gemini-3.6-flash',
        geminiTranslationService: service,
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('translate_input')),
      source,
    );
    FocusScope.of(tester.element(find.byKey(const ValueKey('translate_input'))))
        .unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('engine_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gemini'));
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

    expect(receivedApiKey, 'gemini-key');
    expect(receivedUri?.path, contains('gemini-3.6-flash'));
    expect(
      receivedPrompt,
      'Translate from 任意的語言 to 繁體中文.\n\n'
      '字彙表：\n'
      'useful → 有用的\n\n'
      '文章：\n'
      'A useful sentence for translation.',
    );
    expect(receivedPrompt, isNot(contains('<待翻譯的文章>')));
    expect(find.byKey(const ValueKey('save_article_button')), findsOneWidget);
  });
}
