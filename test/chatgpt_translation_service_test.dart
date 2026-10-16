import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:transhelf/services/chatgpt_translation_service.dart';

void main() {
  test('posts translation prompt to selected OpenAI model', () async {
    late Uri uri;
    late String sentApiKey;
    late Map<String, Object?> body;
    final service = ChatGPTTranslationService(
      post: (requestUri, apiKey, requestBody) async {
        uri = requestUri;
        sentApiKey = apiKey;
        body = requestBody;
        return (
          200,
          jsonEncode({
            'output': [
              {'type': 'reasoning', 'summary': []},
              {
                'type': 'message',
                'role': 'assistant',
                'content': [
                  {'type': 'output_text', 'text': 'translated'},
                ],
              },
            ],
          }),
        );
      },
    );

    final result = await service.translate(
      prompt: 'translate this',
      apiKey: ' test-key ',
      model: 'gpt-4.1-mini',
    );

    expect(result, 'translated');
    expect(uri, Uri.https('api.openai.com', '/v1/responses'));
    expect(sentApiKey, 'test-key');
    expect(body, {
      'model': 'gpt-4.1-mini',
      'input': 'translate this',
      'store': false,
    });
  });

  test('returns OpenAI API error message', () async {
    final service = ChatGPTTranslationService(
      post: (_, _, _) async => (
        401,
        jsonEncode({
          'error': {'message': 'Invalid API key'},
        }),
      ),
    );

    await expectLater(
      service.translate(prompt: 'translate', apiKey: 'bad-key'),
      throwsA(
        isA<ChatGPTTranslationException>()
            .having((error) => error.statusCode, 'status', 401)
            .having((error) => error.message, 'message', 'Invalid API key'),
      ),
    );
  });
}
