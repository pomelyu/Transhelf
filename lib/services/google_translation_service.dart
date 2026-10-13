import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef TranslationPost = Future<(int, String)> Function(
  Uri uri,
  Map<String, Object?> body,
);

class GoogleTranslationException implements Exception {
  const GoogleTranslationException(this.statusCode, this.message);

  final int? statusCode;
  final String message;

  @override
  String toString() => message;
}

class GoogleTranslationService {
  GoogleTranslationService({TranslationPost? post}) : _post = post ?? _httpPost;

  final TranslationPost _post;

  static const maxChunkCharacters = 4500;

  Future<String> translate({
    required String text,
    required String apiKey,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    if (text.trim().isEmpty) return '';
    if (apiKey.trim().isEmpty) {
      throw const GoogleTranslationException(
        null,
        'Missing Google Translate API key',
      );
    }

    final uri = Uri.https(
      'translation.googleapis.com',
      '/language/translate/v2',
      {'key': apiKey.trim()},
    );
    final output = StringBuffer();
    for (final chunk in splitText(text)) {
      if (chunk.trim().isEmpty) {
        output.write(chunk);
        continue;
      }
      final body = <String, Object?>{
        'q': chunk,
        'format': 'text',
        'target': targetLanguage,
        'source': ?sourceLanguage,
      };
      final (status, response) = await _post(uri, body);
      if (status < 200 || status >= 300) {
        String message = 'Google Translation HTTP $status';
        try {
          final decoded = jsonDecode(response) as Map<String, dynamic>;
          final error = decoded['error'] as Map<String, dynamic>?;
          if (error?['message'] is String) {
            message = error!['message'] as String;
          }
        } on FormatException {
          // Keep the status-only message; never echo an unexpected response.
        }
        throw GoogleTranslationException(status, message);
      }
      try {
        final decoded = jsonDecode(response) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>;
        final translations = data['translations'] as List<dynamic>;
        output.write(
          (translations.first as Map<String, dynamic>)['translatedText']
              as String,
        );
      } catch (_) {
        throw const GoogleTranslationException(
          null,
          'Invalid Google Translation response',
        );
      }
    }
    return output.toString();
  }

  static List<String> splitText(String text) {
    final chunks = <String>[];
    final characters = text.runes.toList();
    for (var start = 0; start < characters.length;) {
      var end = (start + maxChunkCharacters).clamp(0, characters.length);
      if (end < characters.length) {
        for (var i = end; i > start + maxChunkCharacters ~/ 2; i--) {
          if (RegExp(r'\s').hasMatch(String.fromCharCode(characters[i - 1]))) {
            end = i;
            break;
          }
        }
      }
      chunks.add(String.fromCharCodes(characters.sublist(start, end)));
      start = end;
    }
    return chunks;
  }

  static Future<(int, String)> _httpPost(
    Uri uri,
    Map<String, Object?> body,
  ) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client
          .postUrl(uri)
          .timeout(const Duration(seconds: 30));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      return (response.statusCode, await utf8.decoder.bind(response).join());
    } on SocketException {
      throw const GoogleTranslationException(null, 'Network connection failed');
    } on TimeoutException {
      throw const GoogleTranslationException(
        null,
        'Google Translation timed out',
      );
    } finally {
      client.close(force: true);
    }
  }
}
