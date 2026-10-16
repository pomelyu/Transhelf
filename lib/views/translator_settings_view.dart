import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/chatgpt_translation_service.dart';
import '../services/gemini_translation_service.dart';
import '../ui/app_palette.dart';

class TranslatorSettingsView extends StatefulWidget {
  const TranslatorSettingsView({
    super.key,
    required this.apiKey,
    required this.onApiKeyChanged,
    required this.geminiApiKey,
    required this.onGeminiApiKeyChanged,
    required this.geminiModel,
    required this.onGeminiModelChanged,
    required this.chatGPTApiKey,
    required this.onChatGPTApiKeyChanged,
    required this.chatGPTModel,
    required this.onChatGPTModelChanged,
  });

  final String apiKey;
  final Future<void> Function(String) onApiKeyChanged;
  final String geminiApiKey;
  final Future<void> Function(String) onGeminiApiKeyChanged;
  final String geminiModel;
  final Future<void> Function(String) onGeminiModelChanged;
  final String chatGPTApiKey;
  final Future<void> Function(String) onChatGPTApiKeyChanged;
  final String chatGPTModel;
  final Future<void> Function(String) onChatGPTModelChanged;

  @override
  State<TranslatorSettingsView> createState() => _TranslatorSettingsViewState();
}

class _TranslatorSettingsViewState extends State<TranslatorSettingsView> {
  late final _controller = TextEditingController(text: widget.apiKey);
  late final _geminiController = TextEditingController(
    text: widget.geminiApiKey,
  );
  late final _chatGPTController = TextEditingController(
    text: widget.chatGPTApiKey,
  );
  late String _selectedGeminiModel =
      GeminiTranslationService.availableModels.contains(widget.geminiModel)
      ? widget.geminiModel
      : GeminiTranslationService.defaultModel;
  late String _selectedChatGPTModel =
      ChatGPTTranslationService.availableModels.contains(widget.chatGPTModel)
      ? widget.chatGPTModel
      : ChatGPTTranslationService.defaultModel;
  bool _visible = false;
  bool _saving = false;
  bool _editing = false;
  late bool _configured = widget.apiKey.isNotEmpty;
  late bool _geminiConfigured = widget.geminiApiKey.isNotEmpty;
  late bool _chatGPTConfigured = widget.chatGPTApiKey.isNotEmpty;
  String? _error;
  String? _notice;
  int _selectedService = 0;

  @override
  void dispose() {
    _controller.dispose();
    _geminiController.dispose();
    _chatGPTController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = switch (_selectedService) {
      0 => _controller,
      1 => _geminiController,
      _ => _chatGPTController,
    };
    final apiKey = controller.text.trim();
    if (apiKey.isEmpty) {
      setState(() => _error = l10n.googleApiKeyHint);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _notice = null;
    });
    try {
      if (_selectedService == 0) {
        await widget.onApiKeyChanged(apiKey);
      } else if (_selectedService == 1) {
        await widget.onGeminiApiKeyChanged(apiKey);
      } else {
        await widget.onChatGPTApiKeyChanged(apiKey);
      }
      if (!mounted) return;
      setState(() {
        if (_selectedService == 0) {
          _configured = true;
        } else if (_selectedService == 1) {
          _geminiConfigured = true;
        } else {
          _chatGPTConfigured = true;
        }
        _editing = false;
        _visible = false;
        _notice = l10n.googleApiKeySaved;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.googleApiKeySaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _selectChatGPTModel(String model) async {
    final previousModel = _selectedChatGPTModel;
    setState(() {
      _selectedChatGPTModel = model;
      _error = null;
      _notice = null;
    });
    try {
      await widget.onChatGPTModelChanged(model);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedChatGPTModel = previousModel;
        _error = AppLocalizations.of(context)!.translatorModelSaveFailed;
      });
    }
  }

  Future<void> _selectGeminiModel(String model) async {
    final previousModel = _selectedGeminiModel;
    setState(() {
      _selectedGeminiModel = model;
      _error = null;
      _notice = null;
    });
    try {
      await widget.onGeminiModelChanged(model);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedGeminiModel = previousModel;
        _error = AppLocalizations.of(context)!.translatorModelSaveFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final services = [l10n.googleTranslateName, 'Gemini', 'ChatGPT'];
    final isGemini = _selectedService == 1;
    final selectedModel = isGemini
        ? _selectedGeminiModel
        : _selectedChatGPTModel;
    final availableModels = isGemini
        ? GeminiTranslationService.availableModels
        : ChatGPTTranslationService.availableModels;
    final displayNames = isGemini
        ? GeminiTranslationService.modelDisplayNames
        : ChatGPTTranslationService.modelDisplayNames;
    final apiKeyController = switch (_selectedService) {
      0 => _controller,
      1 => _geminiController,
      _ => _chatGPTController,
    };
    final activeConfigured = _selectedService == 0
        ? _configured
        : _selectedService == 1
        ? _geminiConfigured
        : _chatGPTConfigured;
    final icons = [
      FLucideIcons.languages,
      FLucideIcons.sparkles,
      FLucideIcons.cloud,
    ];
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  key: const ValueKey('translator_settings_back'),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(FLucideIcons.arrowLeft),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.settingsTranslator,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: List.generate(services.length, (index) {
                final selected = _selectedService == index;
                final configured = switch (index) {
                  0 => _configured,
                  1 => _geminiConfigured,
                  2 => _chatGPTConfigured,
                  _ => false,
                };
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 2 ? 0 : 7),
                    child: InkWell(
                      key: ValueKey('service_tab_$index'),
                      onTap: () => setState(() {
                        _selectedService = index;
                        _error = null;
                        _notice = null;
                        _editing = false;
                        _visible = false;
                      }),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 95,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF292C55)
                              : AppPalette.surface,
                          border: Border.all(
                            color: selected
                                ? AppPalette.blue
                                : AppPalette.border,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icons[index],
                              color: const Color(0xFF9DAEFF),
                              size: 19,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              services[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              configured
                                  ? l10n.googleConfigured
                                  : l10n.googleNotConfigured,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppPalette.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                border: Border.all(color: AppPalette.border),
                borderRadius: BorderRadius.circular(17),
              ),
              child: _selectedService < 3
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                services[_selectedService],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _statusPill(
                              activeConfigured
                                  ? l10n.googleConfigured
                                  : l10n.googlePending,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'API Key',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (!_editing)
                              IconButton(
                                key: ValueKey(switch (_selectedService) {
                                  0 => 'edit_google_api_key',
                                  1 => 'edit_gemini_api_key',
                                  _ => 'edit_chatgpt_api_key',
                                }),
                                tooltip: l10n.googleEditApiKey,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => setState(() {
                                  _editing = true;
                                  _error = null;
                                  _notice = null;
                                }),
                                icon: const Icon(FLucideIcons.pencil, size: 17),
                              ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          key: ValueKey(switch (_selectedService) {
                            0 => 'google_api_key',
                            1 => 'gemini_api_key',
                            _ => 'chatgpt_api_key',
                          }),
                          controller: apiKeyController,
                          enabled: _editing,
                          obscureText: !_visible || !_editing,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            hintText: l10n.googleApiKeyHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            suffixIcon: IconButton(
                              key: const ValueKey('toggle_api_key_visibility'),
                              tooltip: _visible
                                  ? l10n.googleHideApiKey
                                  : l10n.googleShowApiKey,
                              onPressed: _editing
                                  ? () => setState(() => _visible = !_visible)
                                  : null,
                              icon: Icon(
                                _visible
                                    ? FLucideIcons.eyeOff
                                    : FLucideIcons.eye,
                              ),
                            ),
                          ),
                        ),
                        if (_selectedService > 0) ...[
                          const SizedBox(height: 18),
                          Text(
                            l10n.translatorModelLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 7),
                          SizedBox(
                            height: 56,
                            child: InputDecorator(
                              key: ValueKey(
                                isGemini
                                    ? 'gemini_model_selector_container'
                                    : 'chatgpt_model_selector_container',
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  key: ValueKey(
                                    isGemini
                                        ? 'gemini_model_selector'
                                        : 'chatgpt_model_selector',
                                  ),
                                  value: selectedModel,
                                  isExpanded: true,
                                  items: [
                                    for (final model in availableModels)
                                      DropdownMenuItem(
                                        value: model,
                                        child: Text(
                                          displayNames[model] ?? model,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                  onChanged: (model) {
                                    if (model != null) {
                                      if (isGemini) {
                                        _selectGeminiModel(model);
                                      } else {
                                        _selectChatGPTModel(model);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (_notice != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _notice!,
                              style: const TextStyle(
                                color: AppPalette.cyan,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 18),
                        if (_selectedService == 0)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppPalette.surfaceRaised,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  FLucideIcons.languages,
                                  size: 19,
                                  color: AppPalette.cyan,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.googleServiceTip,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      height: 1.5,
                                      color: AppPalette.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_editing) ...[
                          const SizedBox(height: 18),
                          FilledButton(
                            key: ValueKey(switch (_selectedService) {
                              0 => 'save_google_api_key',
                              1 => 'save_gemini_api_key',
                              _ => 'save_chatgpt_api_key',
                            }),
                            onPressed: _saving ? null : _save,
                            child: Text(l10n.googleSaveSettings),
                          ),
                        ],
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          services[_selectedService],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.settingsComingSoon,
                          style: const TextStyle(color: AppPalette.muted),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppPalette.surfaceRaised,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: AppPalette.muted,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
