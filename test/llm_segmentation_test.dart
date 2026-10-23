import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:transhelf/models/translation_preset.dart';
import 'package:transhelf/services/article_segmenter.dart';
import 'package:transhelf/services/llm_segmentation_parser.dart';
import 'package:transhelf/services/llm_prompt_builder.dart';

void main() {
  test('sentence segmentation retains an unpunctuated tail and separators', () {
    const source = 'First sentence.  第二句？\n\nUnpunctuated tail';
    final sentences = ArticleSegmenter.sentences(source);

    expect(sentences, ['First sentence.', '  第二句？', '\n\nUnpunctuated tail']);
    expect(sentences.join(), source);
  });

  test('parser restores source text for contiguous indexed translations', () {
    const sourceSentences = [
      'First sentence.',
      ' Second sentence!',
      '\n\nFinal unpunctuated tail',
    ];
    final segments = LlmSegmentationParser.parse(
      response: jsonEncode([
        {'from': 1, 'to': 2, 'text': '前兩句譯文。'},
        {'from': 3, 'to': 3, 'text': '尾段譯文。'},
      ]),
      sourceSentences: sourceSentences,
    );

    expect(segments, hasLength(2));
    expect(segments[0].source, 'First sentence. Second sentence!');
    expect(segments[0].translation, '前兩句譯文。');
    expect(segments[1].source, 'Final unpunctuated tail');
  });

  test('parser rejects malformed or incomplete segment ranges', () {
    const sentences = ['One.', ' Two.', ' Three.'];
    final invalidResponses = [
      'not json',
      '```json\n[{"from":1,"to":3,"text":"x"}]\n```',
      '[{"from":2,"to":3,"text":"x"}]',
      '[{"from":1,"to":2,"text":"x"},{"from":2,"to":3,"text":"y"}]',
      '[{"from":1,"to":4,"text":"x"}]',
      '[{"from":1,"to":3,"text":" "}]',
    ];

    for (final response in invalidResponses) {
      expect(
        () => LlmSegmentationParser.parse(
          response: response,
          sourceSentences: sentences,
        ),
        throwsA(isA<LlmSegmentationFormatException>()),
        reason: response,
      );
    }
  });

  test(
    'legacy presets default segmentation off and built-in flag persists',
    () {
      final legacyPreset = TranslationPreset.fromJson({
        'id': 'custom',
        'name': 'Custom',
        'prompt': 'Translate.',
      });
      expect(legacyPreset.llmSegmentationEnabled, isFalse);

      final library = PresetLibrarySnapshot.fromJson({
        'presets': [
          {
            'id': TranslationPreset.fallbackId,
            'name': 'Changed name is ignored',
            'prompt': 'Changed prompt is ignored',
            'llmSegmentationEnabled': true,
          },
        ],
        'defaultPresetId': TranslationPreset.fallbackId,
      });
      final fallbackPreset = library.presets.singleWhere(
        (preset) => preset.id == TranslationPreset.fallbackId,
      );
      expect(fallbackPreset.name, TranslationPreset.fallback.name);
      expect(fallbackPreset.prompt, TranslationPreset.fallbackPrompt);
      expect(fallbackPreset.llmSegmentationEnabled, isTrue);
      expect(
        PresetLibrarySnapshot.fromJson(library.toJson()).presets
            .singleWhere((preset) => preset.id == TranslationPreset.fallbackId)
            .llmSegmentationEnabled,
        isTrue,
      );
    },
  );

  test('segmentation prompt is inserted before glossary', () {
    final prompt = LlmPromptBuilder.build(
      customPrompt: 'Translate.',
      glossary: const [
        PresetGlossaryEntry(id: 'term', source: 'source', target: 'target'),
      ],
      sourceLanguage: 'English',
      targetLanguage: '繁體中文',
      article: '["..."]',
      includeLlmSegmentation: true,
    );

    expect(
      prompt.indexOf(LlmPromptBuilder.segmentationFormatPrompt),
      lessThan(prompt.indexOf('字彙表：')),
    );
    expect(prompt, contains('["..."]'));
    expect(prompt, contains('"from": 1'));
  });
}
