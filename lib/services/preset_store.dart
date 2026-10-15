import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/translation_preset.dart';

class PresetStore {
  PresetStore(this._preferences);

  static const storageKey = 'translation_preset_library_v1';

  final SharedPreferences? _preferences;

  Future<PresetLibrarySnapshot> load() async {
    final saved = _preferences?.getString(storageKey);
    if (saved == null) {
      await save(PresetLibrarySnapshot.defaults);
      return PresetLibrarySnapshot.defaults;
    }

    try {
      return PresetLibrarySnapshot.fromJson(
        jsonDecode(saved) as Map<String, dynamic>,
      );
    } on FormatException {
      return PresetLibrarySnapshot.defaults;
    } on TypeError {
      return PresetLibrarySnapshot.defaults;
    }
  }

  Future<void> save(PresetLibrarySnapshot snapshot) async {
    if (_preferences == null) return;
    final saved = await _preferences.setString(
      storageKey,
      jsonEncode(snapshot.toJson()),
    );
    if (!saved) throw StateError('Could not save Preset library.');
  }
}
