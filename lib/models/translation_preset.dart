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
    this.llmSegmentationEnabled = false,
  });

  final String id;
  final String name;
  final String prompt;
  final List<PresetGlossaryEntry> glossary;
  final bool llmSegmentationEnabled;

  static const fallbackId = 'default_translation';
  static const fallbackPrompt =
      r'參考詞彙表，將以下的文章從${source}翻譯成${target}。保留專有名詞和人名不變。';
  static const fallback = TranslationPreset(
    id: fallbackId,
    name: '預設翻譯',
    prompt: fallbackPrompt,
  );

  static const fallbackSafeId = 'default_safe_translation';
  static const fallbackSafePrompt =
      r'參考詞彙表，將以下的文章從${source}翻譯成${target}。保留專有名詞和人名不變。如遇到暴力、露骨等無法翻譯的問題，以符合原意的方式改為含蓄的版本';
  static const fallbackSafe = TranslationPreset(
    id: fallbackSafeId,
    name: '含蓄翻譯',
    prompt: fallbackSafePrompt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'prompt': prompt,
    'glossary': glossary.map((entry) => entry.toJson()).toList(),
    'llmSegmentationEnabled': llmSegmentationEnabled,
  };

  TranslationPreset copyWith({bool? llmSegmentationEnabled}) =>
      TranslationPreset(
        id: id,
        name: name,
        prompt: prompt,
        glossary: glossary,
        llmSegmentationEnabled:
            llmSegmentationEnabled ?? this.llmSegmentationEnabled,
      );

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
        llmSegmentationEnabled:
            json['llmSegmentationEnabled'] as bool? ?? false,
      );

  static const defaults = [fallback, fallbackSafe];
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
      presets[fallbackIndex] = TranslationPreset.fallback.copyWith(
        llmSegmentationEnabled: presets[fallbackIndex].llmSegmentationEnabled,
      );
    }
    if (!presets.any(
      (preset) => preset.id == TranslationPreset.fallbackSafeId,
    )) {
      presets.add(TranslationPreset.fallbackSafe);
    }
    if (presets.isEmpty) {
      throw const FormatException('Preset library cannot be empty.');
    }
    final storedDefault = json['defaultPresetId'] as String?;
    return PresetLibrarySnapshot(
      presets: presets,
      defaultPresetId: presets.any((preset) => preset.id == storedDefault)
          ? storedDefault!
          : TranslationPreset.fallbackSafeId,
    );
  }

  static const defaults = PresetLibrarySnapshot(
    presets: TranslationPreset.defaults,
    defaultPresetId: TranslationPreset.fallbackSafeId,
  );
}
