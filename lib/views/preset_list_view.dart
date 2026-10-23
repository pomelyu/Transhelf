import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/translation_preset.dart';
import '../ui/app_palette.dart';
import '../ui/status_notice.dart';
import 'preset_edit_view.dart';

class PresetListView extends StatefulWidget {
  const PresetListView({
    super.key,
    required this.library,
    required this.onLibraryChanged,
  });

  final PresetLibrarySnapshot library;
  final Future<void> Function(PresetLibrarySnapshot) onLibraryChanged;

  @override
  State<PresetListView> createState() => _PresetListViewState();
}

class _PresetListViewState extends State<PresetListView> {
  late PresetLibrarySnapshot _library = widget.library;
  bool _deleteMode = false;
  final Set<String> _selectedPresetIds = {};

  Future<void> _persist(PresetLibrarySnapshot library) async {
    await widget.onLibraryChanged(library);
    if (mounted) setState(() => _library = library);
  }

  Future<void> _openEditor(TranslationPreset? preset) async {
    final l10n = AppLocalizations.of(context)!;
    if (_deleteMode) return;
    var saved = false;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PresetEditView(
          preset: preset,
          isDefault: preset?.id == _library.defaultPresetId,
          onSetDefault: () async {
            final selectedPreset = preset;
            if (selectedPreset == null) return;
            await _persist(
              PresetLibrarySnapshot(
                presets: _library.presets,
                defaultPresetId: selectedPreset.id,
              ),
            );
          },
          onSave: (edited) async {
            final presets = [..._library.presets];
            final existingIndex = presets.indexWhere(
              (item) => item.id == edited.id,
            );
            if (existingIndex == -1) {
              presets.add(edited);
            } else {
              presets[existingIndex] = edited;
            }
            await _persist(
              PresetLibrarySnapshot(
                presets: presets,
                defaultPresetId: _library.defaultPresetId,
              ),
            );
            saved = true;
          },
        ),
      ),
    );
    if (saved && mounted) {
      StatusNotice.show(context, success: true, message: l10n.presetSaved);
    }
  }

  Future<void> _deleteSelected() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedPresetIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.surface,
        content: Text(l10n.presetDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.articleCancel),
          ),
          FilledButton(
            key: const ValueKey('preset_delete_confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.articleDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final presets = _library.presets
        .where((preset) => !_selectedPresetIds.contains(preset.id))
        .toList();
    final defaultPresetId =
        presets.any((preset) => preset.id == _library.defaultPresetId)
        ? _library.defaultPresetId
        : TranslationPreset.fallbackId;
    try {
      await _persist(
        PresetLibrarySnapshot(
          presets: presets,
          defaultPresetId: defaultPresetId,
        ),
      );
      if (!mounted) return;
      setState(() {
        _selectedPresetIds.clear();
        _deleteMode = false;
      });
      StatusNotice.show(context, success: true, message: l10n.presetDeleted);
    } catch (_) {
      if (!mounted) return;
      StatusNotice.show(
        context,
        success: false,
        message: l10n.presetDeleteFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppPalette.background,
      bottomNavigationBar: _deleteMode
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: OutlinedButton.icon(
                  key: const ValueKey('preset_delete_selected'),
                  onPressed: _selectedPresetIds.isEmpty
                      ? null
                      : _deleteSelected,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: const Color(0xFFFF718F),
                    side: const BorderSide(color: Color(0x59FF718F)),
                    backgroundColor: const Color(0x14FF718F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(FLucideIcons.trash2, size: 18),
                  label: Text(
                    '${l10n.articleDelete}${_selectedPresetIds.isEmpty ? '' : ' (${_selectedPresetIds.length})'}',
                  ),
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('preset_list_back'),
                    tooltip: l10n.readerBack,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(FLucideIcons.arrowLeft),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      l10n.presetManagementTitle,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('preset_add'),
                    tooltip: l10n.presetNewTitle,
                    onPressed: _deleteMode ? null : () => _openEditor(null),
                    icon: const Icon(FLucideIcons.plus),
                  ),
                  IconButton(
                    key: const ValueKey('preset_toggle_delete_mode'),
                    tooltip: _deleteMode
                        ? l10n.presetCloseSelection
                        : l10n.articleDelete,
                    onPressed: _library.presets.length <= 1
                        ? null
                        : () => setState(() {
                            _deleteMode = !_deleteMode;
                            _selectedPresetIds.clear();
                          }),
                    color: _deleteMode ? AppPalette.blue : null,
                    icon: Icon(
                      _deleteMode ? FLucideIcons.x : FLucideIcons.trash2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                itemCount: _library.presets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final preset = _library.presets[index];
                  final selected = _selectedPresetIds.contains(preset.id);
                  final isProtected = preset.id == TranslationPreset.fallbackId;
                  final canSelect =
                      !isProtected &&
                      (selected ||
                          _selectedPresetIds.length <
                              _library.presets.length - 1);
                  return Container(
                    key: ValueKey('preset_card_${preset.id}'),
                    decoration: BoxDecoration(
                      color: AppPalette.surface,
                      border: Border.all(color: AppPalette.border),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Row(
                      children: [
                        if (_deleteMode)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Checkbox(
                              key: ValueKey('preset_select_${preset.id}'),
                              value: selected,
                              onChanged: canSelect
                                  ? (value) => setState(() {
                                      if (value == true) {
                                        _selectedPresetIds.add(preset.id);
                                      } else {
                                        _selectedPresetIds.remove(preset.id);
                                      }
                                    })
                                  : null,
                              activeColor: AppPalette.blue,
                              side: const BorderSide(color: AppPalette.muted),
                            ),
                          ),
                        Expanded(
                          child: InkWell(
                            key: ValueKey('preset_edit_${preset.id}'),
                            onTap: _deleteMode
                                ? null
                                : () => _openEditor(preset),
                            borderRadius: BorderRadius.circular(17),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppPalette.purple.withValues(
                                        alpha: 0.16,
                                      ),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                      FLucideIcons.sparkles,
                                      color: Color(0xFFB5A6FF),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            preset.id ==
                                                    TranslationPreset.fallbackId
                                                ? l10n.presetFallbackName
                                                : preset.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (preset.id ==
                                            _library.defaultPresetId) ...[
                                          const SizedBox(width: 7),
                                          _defaultBadge(l10n.presetDefault),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    FLucideIcons.chevronRight,
                                    color: AppPalette.muted,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultBadge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0x1A22D2E5),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF92E3ED),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
