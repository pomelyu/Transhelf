class PresetGlossaryEntry {
  const PresetGlossaryEntry({
    required this.id,
    required this.source,
    required this.target,
  });

  final String id;
  final String source;
  final String target;

  Map<String, Object?> toJson() => {
    'id': id,
    'source': source,
    'target': target,
  };

  factory PresetGlossaryEntry.fromJson(Map<String, dynamic> json) =>
      PresetGlossaryEntry(
        id: json['id'] as String,
        source: json['source'] as String,
        target: json['target'] as String,
      );
}

class TranslationPreset {
  const TranslationPreset({
    required this.id,
    required this.name,
    required this.prompt,
    this.glossary = const [],
  });

  final String id;
  final String name;
  final String prompt;
  final List<PresetGlossaryEntry> glossary;

  static const fallbackId = 'default_translation';
  static const fallbackPrompt =
      r'參考詞彙表，將以下的文章從${source}翻譯成${target}。保留專有名詞和人名不變。';
  static const fallback = TranslationPreset(
    id: fallbackId,
    name: '預設翻譯',
    prompt: fallbackPrompt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'prompt': prompt,
    'glossary': glossary.map((entry) => entry.toJson()).toList(),
  };

  factory TranslationPreset.fromJson(Map<String, dynamic> json) =>
      TranslationPreset(
        id: json['id'] as String,
        name: json['name'] as String,
        prompt: json['prompt'] as String? ?? '',
        glossary: (json['glossary'] as List<dynamic>? ?? const [])
            .map(
              (entry) =>
                  PresetGlossaryEntry.fromJson(entry as Map<String, dynamic>),
            )
            .toList(),
      );

  static const defaults = [
    fallback,
    TranslationPreset(
      id: 'technical',
      name: '技術文章',
      prompt: '保留常見英文技術名詞，優先使用台灣常用譯法。',
    ),
    TranslationPreset(id: 'natural', name: '自然對話', prompt: '避免逐字翻譯，優先維持對話語氣。'),
    TranslationPreset(
      id: 'summary',
      name: '精簡摘要',
      prompt: '整理為五點以內的摘要，保留關鍵數字。',
    ),
  ];
}

class PresetLibrarySnapshot {
  const PresetLibrarySnapshot({
    required this.presets,
    required this.defaultPresetId,
  });

  final List<TranslationPreset> presets;
  final String defaultPresetId;

  Map<String, Object?> toJson() => {
    'presets': presets.map((preset) => preset.toJson()).toList(),
    'defaultPresetId': defaultPresetId,
  };

  factory PresetLibrarySnapshot.fromJson(Map<String, dynamic> json) {
    final presets = (json['presets'] as List<dynamic>)
        .map(
          (entry) => TranslationPreset.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
    final fallbackIndex = presets.indexWhere(
      (preset) => preset.id == TranslationPreset.fallbackId,
    );
    if (fallbackIndex == -1) {
      presets.insert(0, TranslationPreset.fallback);
    } else {
      presets[fallbackIndex] = TranslationPreset.fallback;
    }
    if (presets.isEmpty) {
      throw const FormatException('Preset library cannot be empty.');
    }
    final storedDefault = json['defaultPresetId'] as String?;
    return PresetLibrarySnapshot(
      presets: presets,
      defaultPresetId: presets.any((preset) => preset.id == storedDefault)
          ? storedDefault!
          : TranslationPreset.fallbackId,
    );
  }

  static const defaults = PresetLibrarySnapshot(
    presets: TranslationPreset.defaults,
    defaultPresetId: 'technical',
  );
}
