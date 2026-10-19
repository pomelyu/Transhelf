import 'dart:convert';

import '../models/article.dart';

class LlmSegmentationFormatException implements Exception {
  const LlmSegmentationFormatException();
}

abstract final class LlmSegmentationParser {
  static List<ArticleSegment> parse({
    required String response,
    required List<String> sourceSentences,
  }) {
    if (sourceSentences.isEmpty) throw const LlmSegmentationFormatException();

    final dynamic decoded;
    try {
      decoded = jsonDecode(response);
    } on FormatException {
      throw const LlmSegmentationFormatException();
    }
    if (decoded is! List || decoded.isEmpty) {
      throw const LlmSegmentationFormatException();
    }

    final segments = <ArticleSegment>[];
    var nextSentence = 1;
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) {
        throw const LlmSegmentationFormatException();
      }
      final from = item['from'];
      final to = item['to'];
      final text = item['text'];
      if (from is! int ||
          to is! int ||
          text is! String ||
          from != nextSentence ||
          to < from ||
          to > sourceSentences.length ||
          text.trim().isEmpty) {
        throw const LlmSegmentationFormatException();
      }

      segments.add(
        ArticleSegment(
          source: sourceSentences.sublist(from - 1, to).join().trim(),
          translation: text.trim(),
        ),
      );
      nextSentence = to + 1;
    }

    if (nextSentence != sourceSentences.length + 1) {
      throw const LlmSegmentationFormatException();
    }
    return segments;
  }
}
