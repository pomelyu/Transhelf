import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef ChatGPTPost = Future<(int, String)> Function(
  Uri uri,
  String apiKey,
  Map<String, Object?> body,
);

class ChatGPTTranslationException implements Exception {
  const ChatGPTTranslationException(this.statusCode, this.message);

  final int? statusCode;
  final String message;

  @override
  String toString() => message;
}

class ChatGPTTranslationService {
  ChatGPTTranslationService({ChatGPTPost? post}) : _post = post ?? _httpPost;

  static const defaultModel = 'gpt-5.4-mini';
  static const availableModels = <String>[
    defaultModel,
    'gpt-4.1-mini',
    'gpt-4.1',
  ];
  static const modelDisplayNames = <String, String>{
    'gpt-5.4-mini': 'GPT-5.4 Mini',
    'gpt-4.1-mini': 'GPT-4.1 Mini',
    'gpt-4.1': 'GPT-4.1',
  };

  final ChatGPTPost _post;

  Future<String> translate({
    required String prompt,
    required String apiKey,
    String model = defaultModel,
  }) async {
    if (prompt.trim().isEmpty) return '';
    if (apiKey.trim().isEmpty) {
      throw const ChatGPTTranslationException(null, 'Missing OpenAI API key');
    }
    if (!availableModels.contains(model)) {
      throw ArgumentError.value(model, 'model', 'Unsupported ChatGPT model');
    }

    final (status, response) = await _post(
      Uri.https('api.openai.com', '/v1/responses'),
      apiKey.trim(),
      {'model': model, 'input': prompt, 'store': false},
    );
    if (status < 200 || status >= 300) {
      var message = 'OpenAI HTTP $status';
      try {
        final decoded = jsonDecode(response) as Map<String, dynamic>;
        final error = decoded['error'] as Map<String, dynamic>?;
        if (error?['message'] is String) {
          message = error!['message'] as String;
        }
      } on FormatException {
        // Keep the status-only message for unexpected error responses.
      }
      throw ChatGPTTranslationException(status, message);
    }

    try {
      final decoded = jsonDecode(response) as Map<String, dynamic>;
      final output = decoded['output'] as List<dynamic>;
      final text = output
          .whereType<Map<String, dynamic>>()
          .where(
            (item) => item['type'] == 'message' && item['role'] == 'assistant',
          )
          .expand((item) => item['content'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .where((item) => item['type'] == 'output_text')
          .map((item) => item['text'])
          .whereType<String>()
          .join();
      if (text.isEmpty) {
        throw const FormatException('OpenAI returned no text.');
      }
      return text;
    } on Object {
      throw const ChatGPTTranslationException(null, 'Invalid OpenAI response');
    }
  }

  static Future<(int, String)> _httpPost(
    Uri uri,
    String apiKey,
    Map<String, Object?> body,
  ) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client
          .postUrl(uri)
          .timeout(const Duration(seconds: 30));
      request.headers
        ..contentType = ContentType.json
        ..set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      request.write(jsonEncode(body));
      final response = await request.close().timeout(
        const Duration(seconds: 60),
      );
      return (
        response.statusCode,
        await response.transform(utf8.decoder).join(),
      );
    } on TimeoutException {
      throw const ChatGPTTranslationException(null, 'OpenAI request timed out');
    } on SocketException {
      throw const ChatGPTTranslationException(
        null,
        'Network connection failed',
      );
    } finally {
      client.close(force: true);
    }
  }
}
