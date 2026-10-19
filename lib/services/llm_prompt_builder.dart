import '../models/translation_preset.dart';

abstract final class LlmPromptBuilder {
  static const segmentationFormatPrompt =
      '分段輸出格式：文章內容是一個 JSON 字串陣列，每一項依序代表一句原文。'
      '請依語意將相鄰句子分組翻譯。只輸出純 JSON 陣列，不要 Markdown code fence 或額外說明。'
      '格式為 [{"from": 1, "to": 5, "text": "該範圍合併後的譯文"}]。'
      'from 與 to 是從 1 開始、包含首尾的句子索引。分段必須依序連續且完整涵蓋每一句，'
      '不得遺漏、重疊、重排；text 只放譯文，不要重複原文。';

  static String build({
    required String customPrompt,
    required List<PresetGlossaryEntry> glossary,
    required String sourceLanguage,
    required String targetLanguage,
    required String article,
    bool includeLlmSegmentation = false,
  }) {
    final glossaryText = glossary
        .map((entry) => '${entry.source} → ${entry.target}')
        .join('\n');
    final segmentationPrompt = includeLlmSegmentation
        ? '$segmentationFormatPrompt\n\n'
        : '';
    return '$customPrompt\n\n'
            '$segmentationPrompt'
            '字彙表：\n'
            '$glossaryText\n\n'
            '文章：\n'
            '<待翻譯的文章>'
        .replaceAll(r'${source}', sourceLanguage)
        .replaceAll(r'${target}', targetLanguage)
        .replaceAll('<待翻譯的文章>', article);
  }
}
