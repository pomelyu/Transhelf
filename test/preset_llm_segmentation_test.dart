import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transhelf/main.dart';
import 'package:transhelf/models/translation_preset.dart';
import 'package:transhelf/services/preset_store.dart';

void main() {
  testWidgets('preset segmentation can be toggled and saved', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final library = PresetLibrarySnapshot(
      presets: [
        TranslationPreset.fallback,
        const TranslationPreset(
          id: 'custom',
          name: 'Custom',
          prompt: 'Translate.',
        ),
      ],
      defaultPresetId: 'custom',
    );
    SharedPreferences.setMockInitialValues({
      PresetStore.storageKey: jsonEncode(library.toJson()),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(TranshelfApp(preferences: preferences));
    await tester.pumpAndSettle();
    await _openPresetEditor(tester);

    final toggle = find.byKey(const ValueKey('preset_llm_segmentation_toggle'));
    expect(tester.widget<FSwitch>(toggle).value, isFalse);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<FSwitch>(toggle).value, isTrue);
    await tester.tap(find.byKey(const ValueKey('preset_save')));
    await tester.pumpAndSettle();

    final saved = PresetLibrarySnapshot.fromJson(
      jsonDecode(preferences.getString(PresetStore.storageKey)!)
          as Map<String, dynamic>,
    );
    expect(
      saved.presets
          .singleWhere((preset) => preset.id == 'custom')
          .llmSegmentationEnabled,
      isTrue,
    );
  });

  testWidgets('copying a preset inherits its segmentation setting', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final library = PresetLibrarySnapshot(
      presets: [
        TranslationPreset.fallback,
        const TranslationPreset(
          id: 'custom',
          name: 'Custom',
          prompt: 'Translate.',
          llmSegmentationEnabled: true,
        ),
      ],
      defaultPresetId: 'custom',
    );
    SharedPreferences.setMockInitialValues({
      PresetStore.storageKey: jsonEncode(library.toJson()),
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(TranshelfApp(preferences: preferences));
    await tester.pumpAndSettle();
    await _openPresetEditor(tester);
    await tester.tap(find.byKey(const ValueKey('preset_copy')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<FSwitch>(
            find.byKey(const ValueKey('preset_llm_segmentation_toggle')),
          )
          .value,
      isTrue,
    );
  });
}

Future<void> _openPresetEditor(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('nav.settings')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('preset_settings')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('preset_edit_custom')));
  await tester.pumpAndSettle();
}
