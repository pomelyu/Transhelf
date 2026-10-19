import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transhelf/main.dart';
import 'package:transhelf/models/translation_preset.dart';
import 'package:transhelf/services/chatgpt_translation_service.dart';
import 'package:transhelf/services/gemini_translation_service.dart';
import 'package:transhelf/services/llm_prompt_builder.dart';
import 'package:transhelf/services/preset_store.dart';

void main() {
  testWidgets('LLM segmentation sends the full indexed sentence list once', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final library = PresetLibrarySnapshot(
      presets: [
        TranslationPreset.fallback,
        const TranslationPreset(
          id: 'segmented',
          name: 'Segmented',
          prompt: r'Translate from ${source} to ${target}.',
          llmSegmentationEnabled: true,
          glossary: [
            PresetGlossaryEntry(id: 'term', source: 'tail', target: '尾段'),
          ],
        ),
      ],
      defaultPresetId: 'segmented',
    );
    SharedPreferences.setMockInitialValues({
      PresetStore.storageKey: jsonEncode(library.toJson()),
    });
    final preferences = await SharedPreferences.getInstance();
    var requestCount = 0;
    String? prompt;
    const source = 'First sentence. Second sentence! Tail without a mark';
    final service = GeminiTranslationService(
      post: (_, _, body) async {
        requestCount++;
        final contents = body['contents']! as List<dynamic>;
        final parts =
            (contents.single as Map<String, dynamic>)['parts']!
                as List<dynamic>;
        prompt = (parts.single as Map<String, dynamic>)['text'] as String;
        return (
          200,
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': jsonEncode([
                        {'from': 1, 'to': 2, 'text': '前兩句譯文。'},
                        {'from': 3, 'to': 3, 'text': '尾段譯文。'},
                      ]),
                    },
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
    expect(preview.data, contains(LlmPromptBuilder.segmentationFormatPrompt));
    expect(preview.data, contains('["..."]'));
    expect(
      preview.data!.indexOf(LlmPromptBuilder.segmentationFormatPrompt),
      lessThan(preview.data!.indexOf('字彙表：')),
    );
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('translate_button')));
    await tester.pumpAndSettle();

    expect(requestCount, 1);
    expect(prompt, contains(LlmPromptBuilder.segmentationFormatPrompt));
    expect(
      prompt,
      contains(
        '["First sentence."," Second sentence!"," Tail without a mark"]',
      ),
    );
    expect(
      prompt!.indexOf(LlmPromptBuilder.segmentationFormatPrompt),
      lessThan(prompt!.indexOf('字彙表：')),
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('translate_output')))
          .controller!
          .text,
      '前兩句譯文。\n\n尾段譯文。',
    );
  });

  testWidgets('ChatGPT LLM segmentation parses indexed translation output', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final library = PresetLibrarySnapshot(
      presets: [
        TranslationPreset.fallback,
        const TranslationPreset(
          id: 'segmented',
          name: 'Segmented',
          prompt: 'Translate.',
          llmSegmentationEnabled: true,
        ),
      ],
      defaultPresetId: 'segmented',
    );
    SharedPreferences.setMockInitialValues({
      PresetStore.storageKey: jsonEncode(library.toJson()),
    });
    final preferences = await SharedPreferences.getInstance();
    var requestCount = 0;
    final service = ChatGPTTranslationService(
      post: (_, _, body) async {
        requestCount++;
        expect(
          body['input'],
          contains('["First sentence."," Second sentence!"]'),
        );
        return (
          200,
          jsonEncode({
            'output': [
              {
                'type': 'message',
                'role': 'assistant',
                'content': [
                  {
                    'type': 'output_text',
                    'text': '[{"from":1,"to":2,"text":"合併譯文。"}]',
                  },
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
        chatGPTTranslationService: service,
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('translate_input')),
      'First sentence. Second sentence!',
    );
    FocusScope.of(tester.element(find.byKey(const ValueKey('translate_input'))))
        .unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('engine_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ChatGPT'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('translate_button')));
    await tester.pumpAndSettle();

    expect(requestCount, 1);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('translate_output')))
          .controller!
          .text,
      '合併譯文。',
    );
  });

  testWidgets(
    'invalid LLM segmentation output shows an error without fallback',
    (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final library = PresetLibrarySnapshot(
        presets: [
          TranslationPreset.fallback,
          const TranslationPreset(
            id: 'segmented',
            name: 'Segmented',
            prompt: 'Translate.',
            llmSegmentationEnabled: true,
          ),
        ],
        defaultPresetId: 'segmented',
      );
      SharedPreferences.setMockInitialValues({
        PresetStore.storageKey: jsonEncode(library.toJson()),
      });
      final preferences = await SharedPreferences.getInstance();
      var requestCount = 0;
      final service = GeminiTranslationService(
        post: (_, _, _) async {
          requestCount++;
          return (
            200,
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': '```json\n[]\n```'},
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
          geminiTranslationService: service,
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('translate_input')),
        'First sentence.',
      );
      FocusScope.of(
        tester.element(find.byKey(const ValueKey('translate_input'))),
      ).unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('engine_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gemini'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('translate_button')));
      await tester.pumpAndSettle();

      expect(requestCount, 1);
      expect(find.byKey(const ValueKey('translate_error')), findsOneWidget);
      expect(find.byKey(const ValueKey('save_article_button')), findsNothing);
    },
  );
}
