import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/article.dart';
import '../services/article_segmenter.dart';
import '../services/google_translation_service.dart';
import '../ui/app_palette.dart';

class TranslateView extends StatefulWidget {
  const TranslateView({
    super.key,
    required this.apiKey,
    required this.onOpenSettings,
    required this.onSaveArticle,
    this.service,
  });

  final String apiKey;
  final VoidCallback onOpenSettings;
  final Future<void> Function(Article) onSaveArticle;
  final GoogleTranslationService? service;

  @override
  State<TranslateView> createState() => _TranslateViewState();
}

class _TranslateViewState extends State<TranslateView> {
  final _source = TextEditingController();
  late final GoogleTranslationService _service =
      widget.service ?? GoogleTranslationService();
  String? _sourceLanguage;
  String _targetLanguage = 'zh-TW';
  String _result = '';
  String? _error;
  bool _busy = false;
  bool _showResult = false;
  List<ArticleSegment> _translatedSegments = [];

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final l10n = AppLocalizations.of(context)!;
    if (_source.text.trim().isEmpty) {
      setState(() => _error = l10n.googleEnterText);
      return;
    }
    if (widget.apiKey.isEmpty) {
      setState(() => _error = l10n.googleConfigureFirst);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _translatedSegments = [];
    });
    try {
      final source = _source.text;
      final segments = <ArticleSegment>[];
      for (final part in ArticleSegmenter.split(source)) {
        final translated = await _service.translate(
          text: part,
          apiKey: widget.apiKey,
          sourceLanguage: _sourceLanguage,
          targetLanguage: _targetLanguage,
        );
        segments.add(ArticleSegment(source: part, translation: translated));
      }
      if (!mounted) return;
      setState(() {
        _result = segments.map((part) => part.translation).join('\n\n');
        _translatedSegments = _source.text == source ? segments : [];
        _showResult = true;
      });
    } on GoogleTranslationException catch (error) {
      if (!mounted) return;
      setState(
        () => _error = error.statusCode == 403
            ? l10n.googleApiKeyInvalid
            : '${l10n.googleTranslationFailed}: ${error.message}',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.googleTranslationFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
    if (title == null || !mounted || _translatedSegments.isEmpty) return;
    final now = DateTime.now();
    final article = Article(
      id: 'article_${now.microsecondsSinceEpoch}',
      title: title,
      createdAt: now,
      sourceLanguage: _sourceLanguage ?? 'auto',
      targetLanguage: _targetLanguage,
      service: 'google',
      segments: List.of(_translatedSegments),
    );
    try {
      await widget.onSaveArticle(article);
      if (mounted) {
        setState(() {
          _result = '';
          _translatedSegments = [];
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.articleSaved)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.articleSaveFailed)));
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
    setState(() {
      _translatedSegments = [];
      if (source) {
        _sourceLanguage = picked == 'auto' ? null : picked;
      } else {
        _targetLanguage = picked;
      }
    });
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
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: _panelDecoration,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _engineDropdown(l10n),
                        const SizedBox(width: 8),
                        _choice(
                          l10n.translatePreset,
                          l10n.googlePresetUnavailable,
                          disabled: true,
                        ),
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
                    _tab(
                      l10n.translateSource,
                      !_showResult,
                      () => setState(() => _showResult = false),
                    ),
                    _tab(
                      l10n.translateResult,
                      _showResult,
                      () => setState(() => _showResult = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _panelDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Translate · ${_showResult ? l10n.translateResult : l10n.translateSource}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppPalette.muted,
                        ),
                      ),
                      const Divider(height: 22, color: AppPalette.border),
                      Expanded(
                        child: _showResult
                            ? SingleChildScrollView(
                                child: SelectableText(
                                  _result.isEmpty
                                      ? l10n.translateOutputHint
                                      : _result,
                                  key: const ValueKey('translate_output'),
                                  style: TextStyle(
                                    color: _result.isEmpty
                                        ? AppPalette.muted
                                        : Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              )
                            : TextField(
                                key: const ValueKey('translate_input'),
                                controller: _source,
                                onChanged: (_) =>
                                    setState(() => _translatedSegments = []),
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
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
                if (widget.apiKey.isEmpty)
                  TextButton(
                    onPressed: widget.onOpenSettings,
                    child: Text(l10n.googleOpenSettings),
                  ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('translate_button'),
                      onPressed: _busy ? null : _translate,
                      child: _busy
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.translateStart),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('save_article_button'),
                      onPressed: _busy || _translatedSegments.isEmpty
                          ? null
                          : _saveArticle,
                      child: Text(l10n.translateSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final _panelDecoration = BoxDecoration(
    color: AppPalette.surface,
    border: Border.all(color: AppPalette.border),
    borderRadius: BorderRadius.circular(17),
  );

  Widget _engineDropdown(AppLocalizations l10n) => Expanded(
    child: PopupMenuButton<int>(
      key: const ValueKey('engine_dropdown'),
      tooltip: l10n.translateEngine,
      color: AppPalette.surfaceRaised,
      itemBuilder: (_) => [
        PopupMenuItem(value: 0, child: Text(l10n.googleTranslateName)),
        const PopupMenuItem(value: 1, enabled: false, child: Text('Gemini')),
        const PopupMenuItem(value: 2, enabled: false, child: Text('ChatGPT')),
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
                    l10n.googleTranslateName,
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
    child: Opacity(
      opacity: disabled ? 0.45 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
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
              if (onTap != null)
                const Icon(
                  FLucideIcons.chevronDown,
                  size: 14,
                  color: AppPalette.muted,
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _tab(String label, bool selected, VoidCallback onTap) => Expanded(
    child: InkWell(
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
