import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/article.dart';
import '../models/translation_preset.dart';
import '../services/article_segmenter.dart';
import '../services/chatgpt_translation_service.dart';
import '../services/gemini_translation_service.dart';
import '../services/google_translation_service.dart';
import '../services/llm_segmentation_parser.dart';
import '../services/llm_prompt_builder.dart';
import '../services/preset_store.dart';
import '../ui/app_palette.dart';
import '../ui/status_notice.dart';

class TranslateView extends StatefulWidget {
  const TranslateView({
    super.key,
    required this.apiKey,
    this.geminiApiKey = '',
    this.geminiModel = GeminiTranslationService.defaultModel,
    this.chatGPTApiKey = '',
    this.chatGPTModel = ChatGPTTranslationService.defaultModel,
    required this.onOpenSettings,
    required this.onSaveArticle,
    this.isActive = true,
    this.service,
    this.geminiService,
    this.chatGPTService,
    this.preferences,
  });

  final String apiKey;
  final String geminiApiKey;
  final String geminiModel;
  final String chatGPTApiKey;
  final String chatGPTModel;
  final VoidCallback onOpenSettings;
  final Future<void> Function(Article) onSaveArticle;
  final bool isActive;
  final GoogleTranslationService? service;
  final GeminiTranslationService? geminiService;
  final ChatGPTTranslationService? chatGPTService;
  final SharedPreferences? preferences;

  @override
  State<TranslateView> createState() => _TranslateViewState();
}

class _TranslateViewState extends State<TranslateView> {
  final _source = TextEditingController();
  final _translation = TextEditingController();
  final _sourceFocus = FocusNode();
  final _translationFocus = FocusNode();
  final _settingsRevision = ValueNotifier<int>(0);
  final _contentRevision = ValueNotifier<int>(0);
  final _editingText = ValueNotifier<bool>(false);
  final _sourceCharacterCount = ValueNotifier<int>(0);
  late final ValueNotifier<_TranslateActionState> _actionState = ValueNotifier(
    _currentActionState,
  );
  late final GoogleTranslationService _service =
      widget.service ?? GoogleTranslationService();
  late final GeminiTranslationService _geminiService =
      widget.geminiService ?? GeminiTranslationService();
  late final ChatGPTTranslationService _chatGPTService =
      widget.chatGPTService ?? ChatGPTTranslationService();
  late final PresetStore _presetStore = PresetStore(widget.preferences);
  PresetLibrarySnapshot _presetLibrary = PresetLibrarySnapshot.defaults;
  String _selectedPresetId = PresetLibrarySnapshot.defaults.defaultPresetId;
  bool _hasManuallySelectedPreset = false;
  int _selectedEngine = 0;
  String? _sourceLanguage;
  String _targetLanguage = 'zh-TW';
  String? _error;
  bool _busy = false;
  bool _showResult = false;
  bool _hasTranslated = false;
  bool _editingResult = false;
  int _translationEpoch = 0;
  List<ArticleSegment> _translatedSegments = [];

  bool get _isEditingText =>
      _sourceFocus.hasFocus || (_editingResult && _translationFocus.hasFocus);

  _TranslateActionState get _currentActionState => _TranslateActionState(
    busy: _busy,
    error: _error,
    hasTranslated: _hasTranslated,
    canSave:
        _hasTranslated &&
        !_busy &&
        _translatedSegments.isNotEmpty &&
        _translation.text.trim().isNotEmpty,
  );

  void _notifySettingsArea() => _settingsRevision.value++;

  void _notifyContentArea() => _contentRevision.value++;

  void _notifyEditingText() => _editingText.value = _isEditingText;

  void _notifyCharacterCount() =>
      _sourceCharacterCount.value = _source.text.length;

  void _notifyActionArea() {
    final next = _currentActionState;
    if (next != _actionState.value) _actionState.value = next;
  }

  void _clearTextFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sourceFocus.unfocus();
      _translationFocus.unfocus();
      _notifyEditingText();
    });
  }

  TranslationPreset get _selectedPreset => _presetLibrary.presets.firstWhere(
    (preset) => preset.id == _selectedPresetId,
    orElse: () => TranslationPreset.fallback,
  );

  Future<void> _refreshPresets() async {
    try {
      final library = await _presetStore.load();
      if (!mounted) return;
      _presetLibrary = library;
      if (!_hasManuallySelectedPreset ||
          !library.presets.any((preset) => preset.id == _selectedPresetId)) {
        _selectedPresetId = library.defaultPresetId;
        _hasManuallySelectedPreset = false;
      }
      _notifySettingsArea();
    } catch (_) {
      // Keep the last loaded preset library available if storage is unavailable.
    }
  }

  void _pickPreset(String picked) {
    _clearTextFocus();
    _selectedPresetId = picked;
    _hasManuallySelectedPreset = true;
    _translatedSegments = [];
    _translation.clear();
    _hasTranslated = false;
    _showResult = false;
    _error = null;
    _notifySettingsArea();
    _notifyContentArea();
    _notifyActionArea();
  }

  List<TranslationPreset> get _orderedPresets => [
    ..._presetLibrary.presets.where(
      (preset) => preset.id == _presetLibrary.defaultPresetId,
    ),
    ..._presetLibrary.presets.where(
      (preset) => preset.id != _presetLibrary.defaultPresetId,
    ),
  ];

  Widget _presetDropdown(AppLocalizations l10n) => Expanded(
    child: PopupMenuButton<String>(
      key: const ValueKey('preset_dropdown'),
      tooltip: l10n.translatePreset,
      color: AppPalette.surfaceRaised,
      position: PopupMenuPosition.under,
      onOpened: _refreshPresets,
      onSelected: _pickPreset,
      itemBuilder: (_) => [
        for (final preset in _orderedPresets)
          PopupMenuItem(
            value: preset.id,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(preset.name),
                if (preset.id == _presetLibrary.defaultPresetId)
                  Text(
                    l10n.presetDefault,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppPalette.muted,
                    ),
                  ),
              ],
            ),
          ),
      ],
      child: _choiceContent(
        l10n.translatePreset,
        _selectedEngine == 0
            ? l10n.googlePresetUnavailable
            : _selectedPreset.name,
        disabled: _selectedEngine == 0,
        showChevron: true,
        useInkWell: false,
      ),
    ),
  );

  Future<void> _showPromptPreview() async {
    final l10n = AppLocalizations.of(context)!;
    final preset = _selectedPreset;
    final includeLlmSegmentation = preset.llmSegmentationEnabled;
    final prompt = LlmPromptBuilder.build(
      customPrompt: preset.prompt,
      glossary: preset.glossary,
      sourceLanguage: _sourceLanguage == null
          ? '任意的語言'
          : _languageName(l10n, _sourceLanguage),
      targetLanguage: _languageName(l10n, _targetLanguage),
      article: includeLlmSegmentation ? jsonEncode(['...']) : '...',
      includeLlmSegmentation: includeLlmSegmentation,
    );
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.surface,
        title: Text(
          l10n.presetPromptPreview,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(child: SelectableText(prompt)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.articleCancel),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _sourceFocus.addListener(_handleFocusChange);
    _translationFocus.addListener(_handleFocusChange);
    _refreshPresets();
  }

  @override
  void didUpdateWidget(covariant TranslateView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _refreshPresets();
    }
  }

  void _handleFocusChange() {
    if (!mounted) return;
    _notifyEditingText();
    if (_isEditingText) {
      _error = null;
      _notifyActionArea();
    }
  }

  @override
  void dispose() {
    _source.dispose();
    _translation.dispose();
    _sourceFocus.dispose();
    _translationFocus.dispose();
    _settingsRevision.dispose();
    _contentRevision.dispose();
    _editingText.dispose();
    _sourceCharacterCount.dispose();
    _actionState.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final l10n = AppLocalizations.of(context)!;
    if (_source.text.trim().isEmpty) {
      _error = l10n.googleEnterText;
      _notifyActionArea();
      return;
    }
    final selectedEngine = _selectedEngine;
    final selectedPreset = _selectedPreset;
    final useLlmSegmentation =
        selectedEngine != 0 && selectedPreset.llmSegmentationEnabled;
    final apiKey = switch (selectedEngine) {
      0 => widget.apiKey,
      1 => widget.geminiApiKey,
      _ => widget.chatGPTApiKey,
    };
    if (apiKey.isEmpty) {
      _error = selectedEngine == 0
          ? l10n.googleConfigureFirst
          : selectedEngine == 1
          ? l10n.geminiConfigureFirst
          : l10n.chatGPTConfigureFirst;
      _notifyActionArea();
      return;
    }
    final requestEpoch = ++_translationEpoch;
    _busy = true;
    _error = null;
    _notifyActionArea();
    try {
      final source = _source.text;
      final segments = <ArticleSegment>[];
      if (useLlmSegmentation) {
        final sentences = ArticleSegmenter.sentences(source);
        final prompt = _buildLlmPrompt(
          l10n: l10n,
          preset: selectedPreset,
          article: jsonEncode(sentences),
          includeLlmSegmentation: true,
        );
        final response = await _requestLlmTranslation(
          engine: selectedEngine,
          prompt: prompt,
          apiKey: apiKey,
        );
        segments.addAll(
          LlmSegmentationParser.parse(
            response: response,
            sourceSentences: sentences,
          ),
        );
      } else {
        for (final part in ArticleSegmenter.split(source)) {
          final String translated;
          if (selectedEngine == 0) {
            translated = await _service.translate(
              text: part,
              apiKey: apiKey,
              sourceLanguage: _sourceLanguage,
              targetLanguage: _targetLanguage,
            );
          } else {
            final prompt = _buildLlmPrompt(
              l10n: l10n,
              preset: selectedPreset,
              article: part,
              includeLlmSegmentation: false,
            );
            translated = await _requestLlmTranslation(
              engine: selectedEngine,
              prompt: prompt,
              apiKey: apiKey,
            );
          }
          if (!mounted || requestEpoch != _translationEpoch) return;
          segments.add(ArticleSegment(source: part, translation: translated));
        }
      }
      if (!mounted || requestEpoch != _translationEpoch) return;
      _sourceFocus.unfocus();
      _translationFocus.unfocus();
      _notifyEditingText();
      _translation.text = segments.map((part) => part.translation).join('\n\n');
      _translatedSegments = _source.text == source ? segments : [];
      _showResult = true;
      _hasTranslated = true;
      _editingResult = false;
      _notifyContentArea();
      _notifySettingsArea();
      _notifyActionArea();
    } on LlmSegmentationFormatException {
      if (!mounted || requestEpoch != _translationEpoch) return;
      _error = l10n.translateLlmSegmentationInvalid;
      _notifyActionArea();
    } on GoogleTranslationException catch (error) {
      if (!mounted || requestEpoch != _translationEpoch) return;
      _error = error.statusCode == 403
          ? l10n.googleApiKeyInvalid
          : '${l10n.googleTranslationFailed}: ${error.message}';
      _notifyActionArea();
    } on GeminiTranslationException catch (error) {
      if (!mounted || requestEpoch != _translationEpoch) return;
      _error = useLlmSegmentation
          ? l10n.translateLlmSegmentationFailed(error.message)
          : error.statusCode == 400 || error.statusCode == 403
          ? l10n.googleApiKeyInvalid
          : '${l10n.geminiTranslationFailed}: ${error.message}';
      _notifyActionArea();
    } on ChatGPTTranslationException catch (error) {
      if (!mounted || requestEpoch != _translationEpoch) return;
      _error = useLlmSegmentation
          ? l10n.translateLlmSegmentationFailed(error.message)
          : error.statusCode == 400 || error.statusCode == 401
          ? l10n.chatGPTApiKeyInvalid
          : '${l10n.chatGPTTranslationFailed}: ${error.message}';
      _notifyActionArea();
    } catch (_) {
      if (!mounted || requestEpoch != _translationEpoch) return;
      _error = useLlmSegmentation
          ? l10n.translateLlmSegmentationRequestFailed
          : selectedEngine == 0
          ? l10n.googleTranslationFailed
          : selectedEngine == 1
          ? l10n.geminiTranslationFailed
          : l10n.chatGPTTranslationFailed;
      _notifyActionArea();
    } finally {
      if (mounted && requestEpoch == _translationEpoch) {
        _busy = false;
        _notifyActionArea();
      }
    }
  }

  String _buildLlmPrompt({
    required AppLocalizations l10n,
    required TranslationPreset preset,
    required String article,
    required bool includeLlmSegmentation,
  }) => LlmPromptBuilder.build(
    customPrompt: preset.prompt,
    glossary: preset.glossary,
    sourceLanguage: _sourceLanguage == null
        ? '任意的語言'
        : _languageName(l10n, _sourceLanguage),
    targetLanguage: _languageName(l10n, _targetLanguage),
    article: article,
    includeLlmSegmentation: includeLlmSegmentation,
  );

  Future<String> _requestLlmTranslation({
    required int engine,
    required String prompt,
    required String apiKey,
  }) => engine == 1
      ? _geminiService.translate(
          prompt: prompt,
          apiKey: apiKey,
          model: widget.geminiModel,
        )
      : _chatGPTService.translate(
          prompt: prompt,
          apiKey: apiKey,
          model: widget.chatGPTModel,
        );

  void _clearSource() {
    _translationEpoch++;
    _source.clear();
    _translation.clear();
    FocusScope.of(context).unfocus();
    _translatedSegments = [];
    _hasTranslated = false;
    _editingResult = false;
    _error = null;
    _busy = false;
    _notifyCharacterCount();
    _notifyContentArea();
    _notifyEditingText();
    _notifyActionArea();
  }

  Future<void> _copyTranslation() async {
    if (_translation.text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _translation.text));
    if (!mounted) return;
    StatusNotice.show(
      context,
      success: true,
      message: AppLocalizations.of(context)!.translateCopied,
    );
  }

  void _toggleResultEditing() {
    _editingResult = !_editingResult;
    _notifyContentArea();
    _notifySettingsArea();
    _notifyEditingText();
    _notifyActionArea();
    if (_editingResult) {
      _translationFocus.requestFocus();
    } else {
      _translationFocus.unfocus();
    }
  }

  List<ArticleSegment> _segmentsForSave() {
    final parts = _translation.text.trim().split(RegExp(r'\r?\n\s*\r?\n'));
    if (parts.length == _translatedSegments.length) {
      return [
        for (var i = 0; i < parts.length; i++)
          ArticleSegment(
            source: _translatedSegments[i].source,
            translation: parts[i].trim(),
          ),
      ];
    }
    return [
      ArticleSegment(
        source: _translatedSegments.map((part) => part.source).join('\n\n'),
        translation: _translation.text.trim(),
      ),
    ];
  }

  Future<void> _saveArticle() async {
    final l10n = AppLocalizations.of(context)!;
    var draft = '';
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          backgroundColor: AppPalette.surface,
          title: Text(l10n.translateSave),
          content: TextField(
            key: const ValueKey('article_title_input'),
            autofocus: true,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: l10n.articleTitle,
              hintText: l10n.articleTitleHint,
            ),
            onChanged: (value) => update(() => draft = value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.articleCancel),
            ),
            FilledButton(
              key: const ValueKey('article_save_confirm'),
              onPressed: draft.trim().isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, draft.trim()),
              child: Text(l10n.articleSaveToShelf),
            ),
          ],
        ),
      ),
    );
    if (title == null ||
        !mounted ||
        _translatedSegments.isEmpty ||
        _translation.text.trim().isEmpty) {
      return;
    }
    final now = DateTime.now();
    final article = Article(
      id: 'article_${now.microsecondsSinceEpoch}',
      title: title,
      createdAt: now,
      sourceLanguage: _sourceLanguage ?? 'auto',
      targetLanguage: _targetLanguage,
      service: switch (_selectedEngine) {
        0 => 'google',
        1 => 'gemini',
        _ => 'chatgpt',
      },
      segments: _segmentsForSave(),
    );
    try {
      await widget.onSaveArticle(article);
      if (mounted) {
        _source.clear();
        _translation.clear();
        _translatedSegments = [];
        _hasTranslated = false;
        _editingResult = false;
        _showResult = false;
        _error = null;
        _notifyCharacterCount();
        _notifyContentArea();
        _notifySettingsArea();
        _notifyEditingText();
        _notifyActionArea();
        StatusNotice.show(context, success: true, message: l10n.articleSaved);
      }
    } catch (_) {
      if (mounted) {
        StatusNotice.show(
          context,
          success: false,
          message: l10n.articleSaveFailed,
        );
      }
    }
  }

  String _languageName(AppLocalizations l10n, String? code) => switch (code) {
    null => l10n.googleDetectLanguage,
    'en' => l10n.languageEnglish,
    'zh-TW' => l10n.languageTraditionalChinese,
    'ja' => l10n.googleJapanese,
    'ko' => l10n.googleKorean,
    _ => code,
  };

  Future<void> _pickLanguage(bool source) async {
    final l10n = AppLocalizations.of(context)!;
    final options = <String?>[if (source) null, 'en', 'zh-TW', 'ja', 'ko'];
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppPalette.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (code) => ListTile(
                  title: Text(_languageName(l10n, code)),
                  onTap: () => Navigator.pop(context, code ?? 'auto'),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (picked == null) return;
    _clearTextFocus();
    _translatedSegments = [];
    if (source) {
      _sourceLanguage = picked == 'auto' ? null : picked;
    } else {
      _targetLanguage = picked;
    }
    _notifySettingsArea();
    _notifyActionArea();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.navTranslate,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _editingText,
                builder: (context, editingText, _) => Column(
                  children: [
                    SizedBox(height: editingText ? 10 : 20),
                    if (!editingText) _buildSettingsArea(l10n),
                  ],
                ),
              ),
              Expanded(child: _buildTranslateArea(l10n)),
              _buildTranslateActions(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsArea(AppLocalizations l10n) =>
      ValueListenableBuilder<int>(
        valueListenable: _settingsRevision,
        builder: (context, _, _) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: _panelDecoration,
              child: Column(
                children: [
                  Row(
                    children: [
                      _engineDropdown(l10n),
                      const SizedBox(width: 8),
                      _presetDropdown(l10n),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _choice(
                        '',
                        _languageName(l10n, _sourceLanguage),
                        onTap: () => _pickLanguage(true),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          FLucideIcons.arrowLeftRight,
                          size: 18,
                          color: AppPalette.muted,
                        ),
                      ),
                      _choice(
                        '',
                        _languageName(l10n, _targetLanguage),
                        onTap: () => _pickLanguage(false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 42,
              decoration: _panelDecoration,
              child: Row(
                children: [
                  _tab(l10n.translateSource, !_showResult, () {
                    _showResult = false;
                    _notifySettingsArea();
                    _notifyContentArea();
                  }, key: const ValueKey('translate_source_tab')),
                  _tab(l10n.translateResult, _showResult, () {
                    _showResult = true;
                    _notifySettingsArea();
                    _notifyContentArea();
                  }, key: const ValueKey('translate_result_tab')),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );

  Widget _buildTranslateArea(AppLocalizations l10n) =>
      ValueListenableBuilder<int>(
        valueListenable: _contentRevision,
        builder: (context, _, _) => ValueListenableBuilder<bool>(
          valueListenable: _editingText,
          builder: (context, editingText, _) => LayoutBuilder(
            builder: (context, constraints) {
              final constrainedWhileEditing =
                  editingText && constraints.maxHeight < 110;
              final verticalPadding = editingText
                  ? (constrainedWhileEditing ? 0.0 : 8.0)
                  : 16.0;
              final toolbarExtent = constrainedWhileEditing ? 24.0 : null;
              final engineName = switch (_selectedEngine) {
                0 => l10n.googleTranslateName,
                1 => 'Gemini',
                _ => 'ChatGPT',
              };
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: verticalPadding,
                ),
                decoration: _panelDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _showResult
                              ? Text(
                                  '$engineName · ${l10n.translateResult}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppPalette.muted,
                                  ),
                                )
                              : ValueListenableBuilder<int>(
                                  valueListenable: _sourceCharacterCount,
                                  builder: (context, count, _) => Text(
                                    '$count ${l10n.translateCharacters}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppPalette.muted,
                                    ),
                                  ),
                                ),
                        ),
                        if (_showResult) ...[
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _translation,
                            builder: (context, value, _) => _toolbarButton(
                              key: const ValueKey('copy_translation_button'),
                              icon: FLucideIcons.copy,
                              tooltip: l10n.translateCopy,
                              compact: editingText,
                              extent: toolbarExtent,
                              onPressed: value.text.isEmpty
                                  ? null
                                  : _copyTranslation,
                            ),
                          ),
                          ValueListenableBuilder<_TranslateActionState>(
                            valueListenable: _actionState,
                            builder: (context, action, _) => _toolbarButton(
                              key: const ValueKey('retranslate_button'),
                              icon: FLucideIcons.refreshCw,
                              tooltip: l10n.translateAgain,
                              compact: editingText,
                              extent: toolbarExtent,
                              onPressed: action.busy ? null : _translate,
                            ),
                          ),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _translation,
                            builder: (context, value, _) => _toolbarButton(
                              key: const ValueKey('edit_translation_button'),
                              icon: _editingResult
                                  ? FLucideIcons.check
                                  : FLucideIcons.pencil,
                              tooltip: _editingResult
                                  ? l10n.translateFinishEditing
                                  : l10n.translateEdit,
                              compact: editingText,
                              extent: toolbarExtent,
                              onPressed: value.text.isEmpty
                                  ? null
                                  : _toggleResultEditing,
                            ),
                          ),
                          if (editingText) _dismissKeyboardButton(l10n),
                        ] else ...[
                          if (_selectedEngine > 0)
                            _toolbarButton(
                              key: const ValueKey('gemini_prompt_preview'),
                              icon: FLucideIcons.eye,
                              tooltip: l10n.presetPromptPreview,
                              compact: editingText,
                              extent: toolbarExtent,
                              onPressed: _showPromptPreview,
                            ),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _source,
                            builder: (context, value, _) => _toolbarButton(
                              key: const ValueKey('clear_source_button'),
                              icon: FLucideIcons.x,
                              tooltip: l10n.translateClearSource,
                              compact: editingText,
                              extent: toolbarExtent,
                              onPressed: value.text.isEmpty
                                  ? null
                                  : _clearSource,
                            ),
                          ),
                          if (editingText)
                            _dismissKeyboardButton(l10n, extent: toolbarExtent),
                        ],
                      ],
                    ),
                    Divider(
                      height: constrainedWhileEditing
                          ? 0
                          : editingText
                          ? 10
                          : 22,
                      color: AppPalette.border,
                    ),
                    Expanded(
                      child: _showResult
                          ? TextField(
                              key: const ValueKey('translate_output'),
                              controller: _translation,
                              focusNode: _translationFocus,
                              readOnly: !_editingResult,
                              onChanged: (_) => _notifyActionArea(),
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              style: const TextStyle(
                                color: Colors.white,
                                height: 1.5,
                              ),
                              decoration: InputDecoration.collapsed(
                                hintText: l10n.translateOutputHint,
                              ),
                            )
                          : TextField(
                              key: const ValueKey('translate_input'),
                              controller: _source,
                              focusNode: _sourceFocus,
                              onChanged: _handleSourceChanged,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration.collapsed(
                                hintText: l10n.translateInputHint,
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

  void _handleSourceChanged(String _) {
    _notifyCharacterCount();
    _translationEpoch++;
    _translatedSegments = [];
    _error = null;
    _busy = false;
    if (_source.text.trim().isEmpty) {
      _translation.clear();
      _hasTranslated = false;
      _editingResult = false;
      _notifyContentArea();
      _notifyEditingText();
    }
    _notifyActionArea();
  }

  Widget _buildTranslateActions(AppLocalizations l10n) =>
      ValueListenableBuilder<_TranslateActionState>(
        valueListenable: _actionState,
        builder: (context, action, _) => Column(
          children: [
            if (action.error != null) ...[
              const SizedBox(height: 8),
              Text(
                key: const ValueKey('translate_error'),
                action.error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
              if (switch (_selectedEngine) {
                0 => widget.apiKey,
                1 => widget.geminiApiKey,
                _ => widget.chatGPTApiKey,
              }.isEmpty)
                TextButton(
                  onPressed: widget.onOpenSettings,
                  child: Text(l10n.googleOpenSettings),
                ),
            ],
            const SizedBox(height: 10),
            if (action.hasTranslated)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const ValueKey('save_article_button'),
                  onPressed: action.canSave ? _saveArticle : null,
                  child: Text(l10n.translateSave),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('translate_button'),
                  onPressed: action.busy ? null : _translate,
                  child: action.busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.translateStart),
                ),
              ),
          ],
        ),
      );

  static final _panelDecoration = BoxDecoration(
    color: AppPalette.surface,
    border: Border.all(color: AppPalette.border),
    borderRadius: BorderRadius.circular(17),
  );

  Widget _toolbarButton({
    required Key key,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool compact = false,
    double? extent,
  }) => IconButton(
    key: key,
    tooltip: tooltip,
    onPressed: onPressed,
    visualDensity: VisualDensity.compact,
    constraints: BoxConstraints(
      minWidth: extent ?? (compact ? 32 : 36),
      minHeight: extent ?? (compact ? 32 : 36),
    ),
    padding: EdgeInsets.zero,
    icon: Icon(icon, size: 18),
  );

  Widget _dismissKeyboardButton(AppLocalizations l10n, {double? extent}) =>
      _toolbarButton(
        key: const ValueKey('dismiss_translate_keyboard_button'),
        icon: FLucideIcons.keyboardOff,
        tooltip: l10n.translateDismissKeyboard,
        compact: true,
        extent: extent,
        onPressed: () => FocusScope.of(context).unfocus(),
      );

  Widget _engineDropdown(AppLocalizations l10n) => Expanded(
    child: PopupMenuButton<int>(
      key: const ValueKey('engine_dropdown'),
      tooltip: l10n.translateEngine,
      color: AppPalette.surfaceRaised,
      onSelected: (engine) {
        _clearTextFocus();
        _selectedEngine = engine;
        _translation.clear();
        _translatedSegments = [];
        _hasTranslated = false;
        _showResult = false;
        _editingResult = false;
        _error = null;
        _notifySettingsArea();
        _notifyContentArea();
        _notifyEditingText();
        _notifyActionArea();
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 0, child: Text(l10n.googleTranslateName)),
        const PopupMenuItem(value: 1, child: Text('Gemini')),
        const PopupMenuItem(value: 2, child: Text('ChatGPT')),
      ],
      child: Container(
        height: 49,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppPalette.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translateEngine,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppPalette.muted,
                    ),
                  ),
                  Text(
                    switch (_selectedEngine) {
                      0 => l10n.googleTranslateName,
                      1 => 'Gemini',
                      _ => 'ChatGPT',
                    },
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              FLucideIcons.chevronDown,
              size: 14,
              color: AppPalette.muted,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _choice(
    String label,
    String value, {
    VoidCallback? onTap,
    bool disabled = false,
  }) => Expanded(
    child: _choiceContent(label, value, onTap: onTap, disabled: disabled),
  );

  Widget _choiceContent(
    String label,
    String value, {
    VoidCallback? onTap,
    bool disabled = false,
    bool showChevron = false,
    bool useInkWell = true,
  }) {
    final field = Container(
      height: 49,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label.isNotEmpty)
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppPalette.muted,
                    ),
                  ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null || showChevron)
            const Icon(
              FLucideIcons.chevronDown,
              size: 14,
              color: AppPalette.muted,
            ),
        ],
      ),
    );
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: useInkWell
          ? InkWell(
              onTap: disabled ? null : onTap,
              borderRadius: BorderRadius.circular(12),
              child: field,
            )
          : field,
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap, {Key? key}) =>
      Expanded(
        child: InkWell(
          key: key,
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppPalette.surfaceRaised : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? Colors.white : AppPalette.muted,
              ),
            ),
          ),
        ),
      );
}

class _TranslateActionState {
  const _TranslateActionState({
    required this.busy,
    required this.error,
    required this.hasTranslated,
    required this.canSave,
  });

  final bool busy;
  final String? error;
  final bool hasTranslated;
  final bool canSave;

  @override
  bool operator ==(Object other) =>
      other is _TranslateActionState &&
      other.busy == busy &&
      other.error == error &&
      other.hasTranslated == hasTranslated &&
      other.canSave == canSave;

  @override
  int get hashCode => Object.hash(busy, error, hasTranslated, canSave);
}
