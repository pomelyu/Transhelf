import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/translation_preset.dart';
import '../ui/app_palette.dart';

class PresetEditView extends StatefulWidget {
  const PresetEditView({
    super.key,
    required this.preset,
    required this.onSave,
    required this.isDefault,
    required this.onSetDefault,
  });

  final TranslationPreset? preset;
  final Future<void> Function(TranslationPreset) onSave;
  final bool isDefault;
  final Future<void> Function() onSetDefault;

  @override
  State<PresetEditView> createState() => _PresetEditViewState();
}

class _PresetEditViewState extends State<PresetEditView> {
  late final _name = TextEditingController(text: widget.preset?.name ?? '');
  late final _prompt = TextEditingController(text: widget.preset?.prompt ?? '');
  final _nameFocusNode = FocusNode();
  late String _presetId =
      widget.preset?.id ?? 'preset_${DateTime.now().microsecondsSinceEpoch}';
  late List<PresetGlossaryEntry> _glossary = _isFallback
      ? []
      : [...?widget.preset?.glossary];
  bool _deleteMode = false;
  bool _saving = false;
  String? _error;
  final Set<String> _selectedTermIds = {};
  final Map<String, FocusNode> _termFocusNodes = {};
  late bool _isDefault = widget.isDefault;
  bool _isCopyDraft = false;
  bool get _isFallback => _presetId == TranslationPreset.fallbackId;

  @override
  void dispose() {
    _name.dispose();
    _prompt.dispose();
    _nameFocusNode.dispose();
    for (final focusNode in _termFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _copyPreset() {
    final copiedTerms = _glossary
        .map(
          (entry) => PresetGlossaryEntry(
            id: 'term_${DateTime.now().microsecondsSinceEpoch}_${entry.id}',
            source: entry.source,
            target: entry.target,
          ),
        )
        .toList();
    for (final focusNode in _termFocusNodes.values) {
      focusNode.dispose();
    }
    _termFocusNodes.clear();
    setState(() {
      _presetId = 'preset_${DateTime.now().microsecondsSinceEpoch}';
      _name.text = '${_name.text}-copy';
      _glossary = copiedTerms;
      _selectedTermIds.clear();
      _deleteMode = false;
      _isDefault = false;
      _isCopyDraft = true;
      _error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _nameFocusNode.canRequestFocus) {
        _nameFocusNode.requestFocus();
      }
    });
  }

  void _addGlossaryTerm() {
    final id = 'term_${DateTime.now().microsecondsSinceEpoch}';
    final focusNode = FocusNode();
    _termFocusNodes[id] = focusNode;
    setState(() {
      _glossary = [
        ..._glossary,
        PresetGlossaryEntry(id: id, source: '', target: ''),
      ];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && focusNode.canRequestFocus) focusNode.requestFocus();
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(
        TranslationPreset(
          id: _presetId,
          name: _isFallback
              ? TranslationPreset.fallback.name
              : _name.text.trim(),
          prompt: _isFallback
              ? TranslationPreset.fallbackPrompt
              : _prompt.text.trim(),
          glossary: _isFallback ? const [] : List.of(_glossary),
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.presetSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteSelectedTerms() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedTermIds.isEmpty) return;
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
            key: const ValueKey('preset_term_delete_confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.articleDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      for (final id in _selectedTermIds) {
        _termFocusNodes.remove(id)?.dispose();
      }
      _glossary.removeWhere((entry) => _selectedTermIds.contains(entry.id));
      _selectedTermIds.clear();
      _deleteMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('preset_edit_back'),
                    tooltip: l10n.readerBack,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(FLucideIcons.arrowLeft),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.preset == null
                          ? l10n.presetNewTitle
                          : l10n.presetEditTitle,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (widget.preset != null && !_isCopyDraft)
                    TextButton.icon(
                      key: const ValueKey('preset_set_default'),
                      onPressed: _isDefault
                          ? null
                          : () async {
                              await widget.onSetDefault();
                              if (mounted) setState(() => _isDefault = true);
                            },
                      icon: Icon(
                        _isDefault ? FLucideIcons.check : FLucideIcons.star,
                        size: 16,
                      ),
                      label: Text(l10n.presetSetDefault),
                    ),
                  if (widget.preset != null)
                    IconButton(
                      key: const ValueKey('preset_copy'),
                      tooltip: l10n.presetCopy,
                      onPressed: _copyPreset,
                      icon: const Icon(FLucideIcons.copy),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  _label(l10n.presetName),
                  TextField(
                    key: const ValueKey('preset_name_input'),
                    controller: _name,
                    focusNode: _nameFocusNode,
                    enabled: !_isFallback,
                    autofocus: widget.preset == null,
                    maxLength: 24,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(hintText: l10n.presetNameHint),
                  ),
                  const SizedBox(height: 7),
                  _label(l10n.presetPrompt),
                  TextField(
                    key: const ValueKey('preset_prompt_input'),
                    controller: _prompt,
                    enabled: !_isFallback,
                    maxLength: 240,
                    minLines: 5,
                    maxLines: 7,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: _inputDecoration(
                      hintText: l10n.presetPromptHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _glossarySection(l10n),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      key: const ValueKey('preset_error'),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                child: _deleteMode
                    ? OutlinedButton.icon(
                        key: const ValueKey('preset_term_delete_selected'),
                        onPressed: _selectedTermIds.isEmpty
                            ? null
                            : _deleteSelectedTerms,
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
                          '${l10n.articleDelete}${_selectedTermIds.isEmpty ? '' : ' (${_selectedTermIds.length})'}',
                        ),
                      )
                    : FilledButton.icon(
                        key: const ValueKey('preset_save'),
                        onPressed: _saving || _name.text.trim().isEmpty
                            ? null
                            : _save,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(FLucideIcons.save, size: 18),
                        label: Text(l10n.presetSave),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glossarySection(AppLocalizations l10n) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppPalette.surface,
      border: Border.all(color: AppPalette.border),
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.presetGlossary,
                style: const TextStyle(
                  color: AppPalette.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              key: const ValueKey('preset_add_term'),
              onPressed: _deleteMode || _isFallback ? null : _addGlossaryTerm,
              icon: const Icon(FLucideIcons.plus, size: 15),
              label: Text(l10n.presetAddTerm),
            ),
            IconButton(
              key: const ValueKey('preset_toggle_term_delete_mode'),
              tooltip: _deleteMode
                  ? l10n.presetCloseSelection
                  : l10n.articleDelete,
              onPressed: _glossary.isEmpty || _isFallback
                  ? null
                  : () => setState(() {
                      _deleteMode = !_deleteMode;
                      _selectedTermIds.clear();
                    }),
              visualDensity: VisualDensity.compact,
              icon: Icon(
                _deleteMode ? FLucideIcons.x : FLucideIcons.trash2,
                size: 17,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_glossary.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: AppPalette.border),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              l10n.presetEmptyGlossary,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppPalette.muted, fontSize: 13),
            ),
          )
        else
          for (final entry in _glossary) ...[
            if (_glossary.first.id != entry.id) const SizedBox(height: 8),
            Row(
              children: [
                if (_deleteMode)
                  Checkbox(
                    key: ValueKey('preset_term_select_${entry.id}'),
                    value: _selectedTermIds.contains(entry.id),
                    onChanged: (value) => setState(() {
                      if (value == true) {
                        _selectedTermIds.add(entry.id);
                      } else {
                        _selectedTermIds.remove(entry.id);
                      }
                    }),
                    activeColor: AppPalette.blue,
                    side: const BorderSide(color: AppPalette.muted),
                  ),
                Expanded(
                  child: _termField(
                    key: ValueKey('preset_term_source_${entry.id}'),
                    label: l10n.presetSourceTerm,
                    placeholder: l10n.readerSource,
                    initialValue: entry.source,
                    enabled: !_deleteMode && !_isFallback,
                    focusNode: _termFocusNodes.putIfAbsent(
                      entry.id,
                      FocusNode.new,
                    ),
                    onChanged: (value) => _updateTerm(entry.id, source: value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _termField(
                    key: ValueKey('preset_term_target_${entry.id}'),
                    label: l10n.presetTargetTerm,
                    placeholder: l10n.readerTranslation,
                    initialValue: entry.target,
                    enabled: !_deleteMode && !_isFallback,
                    onChanged: (value) => _updateTerm(entry.id, target: value),
                  ),
                ),
              ],
            ),
          ],
      ],
    ),
  );

  void _updateTerm(String id, {String? source, String? target}) {
    final index = _glossary.indexWhere((entry) => entry.id == id);
    if (index == -1) return;
    final current = _glossary[index];
    _glossary[index] = PresetGlossaryEntry(
      id: current.id,
      source: source ?? current.source,
      target: target ?? current.target,
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );

  Widget _termField({
    required Key key,
    required String label,
    required String placeholder,
    required String initialValue,
    required bool enabled,
    FocusNode? focusNode,
    required ValueChanged<String> onChanged,
  }) => Semantics(
    label: label,
    child: TextFormField(
      key: key,
      initialValue: initialValue,
      focusNode: focusNode,
      enabled: enabled,
      onChanged: onChanged,
      decoration: _inputDecoration(hintText: placeholder),
      style: const TextStyle(fontSize: 13),
    ),
  );

  InputDecoration _inputDecoration({
    required String hintText,
    String? semanticLabel,
  }) => InputDecoration(
    hintText: hintText,
    labelText: semanticLabel,
    filled: true,
    fillColor: AppPalette.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppPalette.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppPalette.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppPalette.blue),
    ),
  );
}
