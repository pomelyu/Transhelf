import 'package:flutter_test/flutter_test.dart';
import 'package:transhelf/models/translation_preset.dart';

void main() {
  test('built-in default preset id refers to an available preset', () {
    final library = PresetLibrarySnapshot.defaults;

    expect(
      library.presets.any((preset) => preset.id == library.defaultPresetId),
      isTrue,
    );
    expect(library.defaultPresetId, TranslationPreset.fallbackSafeId);
  });

  test('loading a library adds the safe built-in preset when missing', () {
    final library = PresetLibrarySnapshot.fromJson({
      'presets': [TranslationPreset.fallback.toJson()],
      'defaultPresetId': TranslationPreset.fallbackId,
    });

    expect(
      library.presets.any(
        (preset) => preset.id == TranslationPreset.fallbackSafeId,
      ),
      isTrue,
    );
  });
}
