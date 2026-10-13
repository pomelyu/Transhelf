import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:transhelf/services/google_translation_service.dart';

void main() {
  test('posts Basic v2 text request with API key and no LLM model', () async {
    late Uri uri;
    late Map<String, Object?> body;
    final service = GoogleTranslationService(
      post: (requestUri, requestBody) async {
        uri = requestUri;
        body = requestBody;
        return (
          200,
          jsonEncode({
            'data': {
              'translations': [
                {'translatedText': '你好'},
              ],
            },
          }),
        );
      },
    );

    final result = await service.translate(
      text: 'Hello',
      apiKey: 'secret',
      sourceLanguage: 'en',
      targetLanguage: 'zh-TW',
    );

    expect(result, '你好');
    expect(
      uri.toString(),
      'https://translation.googleapis.com/language/translate/v2?key=secret',
    );
    expect(body, {
      'q': 'Hello',
      'format': 'text',
      'target': 'zh-TW',
      'source': 'en',
    });
  });

  test('splits long text without losing source characters', () {
    final input = '${'Hello world. ' * 1000}🧪';
    final chunks = GoogleTranslationService.splitText(input);
    expect(chunks.length, greaterThan(2));
    expect(chunks.join(), input);
    expect(chunks.every((chunk) => chunk.runes.length <= 4500), isTrue);
  });

  test('returns status for API error', () async {
    final service = GoogleTranslationService(
      post: (_, _) async => (
        403,
        jsonEncode({
          'error': {'message': 'Unauthenticated'},
        }),
      ),
    );
    await expectLater(
      service.translate(text: 'Hello', apiKey: 'secret', targetLanguage: 'ja'),
      throwsA(
        isA<GoogleTranslationException>().having(
          (e) => e.statusCode,
          'status',
          403,
        ),
      ),
    );
  });
}
