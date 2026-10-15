import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/translation_preset.dart';

typedef GeminiPost = Future<(int, String)> Function(
  Uri uri,
  String apiKey,
  Map<String, Object?> body,
);

class GeminiTranslationException implements Exception {
  const GeminiTranslationException(this.statusCode, this.message);

  final int? statusCode;
  final String message;

  @override
  String toString() => message;
}

abstract final class GeminiPromptBuilder {
  static String build({
    required String customPrompt,
    required List<PresetGlossaryEntry> glossary,
    required String sourceLanguage,
    required String targetLanguage,
    required String article,
  }) {
    final glossaryText = glossary
        .map((entry) => '${entry.source} → ${entry.target}')
        .join('\n');
    return '$customPrompt\n\n'
            '字彙表：\n'
            '$glossaryText\n\n'
            '文章：\n'
            '<待翻譯的文章>'
        .replaceAll(r'${source}', sourceLanguage)
        .replaceAll(r'${target}', targetLanguage)
        .replaceAll('<待翻譯的文章>', article);
  }
}

class GeminiTranslationService {
  GeminiTranslationService({GeminiPost? post}) : _post = post ?? _httpPost;

  static const defaultModel = 'gemini-3.8-flash';
  static const availableModels = <String>[
    defaultModel,
    'gemini-3.6-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.1-pro-preview',
  ];
  static const modelDisplayNames = <String, String>{
    'gemini-3.8-flash': 'Gemini 3.8 Flash',
    'gemini-3.6-flash': 'Gemini 3.6 Flash',
    'gemini-3.5-flash-lite': 'Gemini 3.5 Flash-Lite',
    'gemini-3.1-pro-preview': 'Gemini 3.1 Pro Preview',
  };

  final GeminiPost _post;

  Future<String> translate({
    required String prompt,
    required String apiKey,
    String model = defaultModel,
  }) async {
    if (prompt.trim().isEmpty) return '';
    if (apiKey.trim().isEmpty) {
      throw const GeminiTranslationException(null, 'Missing Gemini API key');
    }
    if (!availableModels.contains(model)) {
      throw ArgumentError.value(model, 'model', 'Unsupported Gemini model');
    }

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$model:generateContent',
    );
    final body = <String, Object?>{
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
    };
    final (status, response) = await _post(uri, apiKey.trim(), body);
    if (status < 200 || status >= 300) {
      var message = 'Gemini HTTP $status';
      try {
        final decoded = jsonDecode(response) as Map<String, dynamic>;
        final error = decoded['error'] as Map<String, dynamic>?;
        if (error?['message'] is String) {
          message = error!['message'] as String;
        }
      } on FormatException {
        // Keep the status-only message; never echo an unexpected response.
      }
      throw GeminiTranslationException(status, message);
    }

    try {
      final decoded = jsonDecode(response) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>;
      final content =
          (candidates.first as Map<String, dynamic>)['content']
              as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      final text = parts
          .map((part) => (part as Map<String, dynamic>)['text'])
          .whereType<String>()
          .join();
      if (text.isEmpty) {
        throw const FormatException('Gemini returned no text.');
      }
      return text;
    } on Object {
      throw const GeminiTranslationException(null, 'Invalid Gemini response');
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
        ..set('x-goog-api-key', apiKey);
      request.write(jsonEncode(body));
      final response = await request.close().timeout(
        const Duration(seconds: 60),
      );
      return (
        response.statusCode,
        await response.transform(utf8.decoder).join(),
      );
    } on TimeoutException {
      throw const GeminiTranslationException(null, 'Gemini request timed out');
    } on SocketException {
      throw const GeminiTranslationException(null, 'Network connection failed');
    } finally {
      client.close(force: true);
    }
  }
}
