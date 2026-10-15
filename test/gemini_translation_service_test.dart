import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:transhelf/models/translation_preset.dart';
import 'package:transhelf/services/gemini_translation_service.dart';

void main() {
  test('builds a complete prompt with language and article substitutions', () {
    final prompt = GeminiPromptBuilder.build(
      customPrompt: r'將${source}翻譯成${target}。',
      glossary: const [
        PresetGlossaryEntry(id: '1', source: 'book', target: '書'),
      ],
      sourceLanguage: '任意的語言',
      targetLanguage: '繁體中文',
      article: 'Books are useful.',
    );

    expect(
      prompt,
      '將任意的語言翻譯成繁體中文。\n\n'
      '字彙表：\n'
      'book → 書\n\n'
      '文章：\n'
      'Books are useful.',
    );
    expect(prompt, isNot(contains(r'${source}')));
    expect(prompt, isNot(contains(r'${target}')));
    expect(prompt, isNot(contains('<待翻譯的文章>')));
  });

  test(
    'posts prompt to configured Gemini model and reads response text',
    () async {
      late Uri uri;
      late String sentApiKey;
      late Map<String, Object?> body;
      final service = GeminiTranslationService(
        post: (requestUri, apiKey, requestBody) async {
          uri = requestUri;
          sentApiKey = apiKey;
          body = requestBody;
          return (
            200,
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': '有用的書籍。'},
                    ],
                  },
                },
              ],
            }),
          );
        },
      );

      final result = await service.translate(
        prompt: 'translate',
        apiKey: ' key ',
      );

      expect(result, '有用的書籍。');
      expect(
        uri.toString(),
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '${GeminiTranslationService.defaultModel}:generateContent',
      );
      expect(sentApiKey, 'key');
      expect(body, {
        'contents': [
          {
            'parts': [
              {'text': 'translate'},
            ],
          },
        ],
      });
      expect(
        GeminiTranslationService.availableModels,
        contains(GeminiTranslationService.defaultModel),
      );
    },
  );

  test('returns API error status and message', () async {
    final service = GeminiTranslationService(
      post: (_, _, _) async => (
        403,
        jsonEncode({
          'error': {'message': 'API key not authorized'},
        }),
      ),
    );

    await expectLater(
      service.translate(prompt: 'translate', apiKey: 'key'),
      throwsA(
        isA<GeminiTranslationException>()
            .having((error) => error.statusCode, 'status', 403)
            .having(
              (error) => error.message,
              'message',
              'API key not authorized',
            ),
      ),
    );
  });
}
