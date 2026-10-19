import '../models/translation_preset.dart';

abstract final class LlmPromptBuilder {
  static const segmentationFormatPrompt =
      '待翻譯的文章以一個字串陣列表示，每一項依序代表一句原文。'
      '請依語意將相鄰句子分組翻譯，並輸出成格式為 [{"from": 1, "to": 5, "text": "該範圍合併後的譯文"}]的JSON陣列字串。'
      '只輸出純 JSON 陣列，不要有任何額外說明'
      'from 與 to 是從 1 開始、包含首尾的句子索引。分段必須依序連續且完整涵蓋每一句，'
      '不得遺漏、重疊、重排。text只放譯文，不要重複原文。';

  static const normalFormatPrompt = '只輸出翻譯結果，不重複原文，不要有任何額外說明';

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
        : '$normalFormatPrompt\n\n';
    return '$customPrompt\n\n'
            '輸出格式：\n'
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
