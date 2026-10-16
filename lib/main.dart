import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_l10n;
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/generated/app_localizations.dart';
import 'models/article.dart';
import 'models/translation_preset.dart';
import 'services/article_store.dart';
import 'services/google_translation_service.dart';
import 'services/gemini_translation_service.dart';
import 'services/chatgpt_translation_service.dart';
import 'services/preset_store.dart';
import 'services/private_pin_store.dart';
import 'ui/app_palette.dart';
import 'views/reading_view.dart';
import 'views/preset_list_view.dart';
import 'views/setting_view.dart';
import 'views/shelf_view.dart';
import 'views/translate_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final apiKey = preferences.getString('google_translate_api_key') ?? '';
  final geminiApiKey = preferences.getString('gemini_api_key') ?? '';
  final storedGeminiModel = preferences.getString('gemini_model');
  final geminiModel =
      GeminiTranslationService.availableModels.contains(storedGeminiModel)
      ? storedGeminiModel!
      : GeminiTranslationService.defaultModel;
  final chatGptApiKey = preferences.getString('chatgpt_api_key') ?? '';
  final storedChatGptModel = preferences.getString('chatgpt_model');
  final chatGptModel =
      ChatGPTTranslationService.availableModels.contains(storedChatGptModel)
      ? storedChatGptModel!
      : ChatGPTTranslationService.defaultModel;
  runApp(
    TranshelfApp(
      preferences: preferences,
      initialApiKey: apiKey,
      initialGeminiApiKey: geminiApiKey,
      initialGeminiModel: geminiModel,
      initialChatGPTApiKey: chatGptApiKey,
      initialChatGPTModel: chatGptModel,
    ),
  );
}

class TranshelfApp extends StatefulWidget {
  const TranshelfApp({
    super.key,
    this.preferences,
    this.initialApiKey = '',
    this.initialGeminiApiKey = '',
    this.initialGeminiModel = GeminiTranslationService.defaultModel,
    this.initialChatGPTApiKey = '',
    this.initialChatGPTModel = ChatGPTTranslationService.defaultModel,
    this.articleStore,
    this.translationService,
    this.geminiTranslationService,
    this.chatGPTTranslationService,
  });

  final SharedPreferences? preferences;
  final String initialApiKey;
  final String initialGeminiApiKey;
  final String initialGeminiModel;
  final String initialChatGPTApiKey;
  final String initialChatGPTModel;
  final ArticleStore? articleStore;
  final GoogleTranslationService? translationService;
  final GeminiTranslationService? geminiTranslationService;
  final ChatGPTTranslationService? chatGPTTranslationService;

  @override
  State<TranshelfApp> createState() => _TranshelfAppState();
}

class _TranshelfAppState extends State<TranshelfApp> {
  late String _googleApiKey = widget.initialApiKey;
  late String _geminiApiKey = widget.initialGeminiApiKey;
  late String _geminiModel = widget.initialGeminiModel;
  late String _chatGPTApiKey = widget.initialChatGPTApiKey;
  late String _chatGPTModel = widget.initialChatGPTModel;
  late Locale _locale = widget.preferences?.getString('app_locale') == 'en'
      ? const Locale('en')
      : const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        );

  void _changeLocale(Locale locale) {
    setState(() => _locale = locale);
    widget.preferences?.setString('app_locale', locale.languageCode);
  }

  Future<void> _changeGoogleApiKey(String apiKey) async {
    await widget.preferences?.setString('google_translate_api_key', apiKey);
    if (mounted) setState(() => _googleApiKey = apiKey);
  }

  Future<void> _changeGeminiApiKey(String apiKey) async {
    await widget.preferences?.setString('gemini_api_key', apiKey);
    if (mounted) setState(() => _geminiApiKey = apiKey);
  }

  Future<void> _changeGeminiModel(String model) async {
    await widget.preferences?.setString('gemini_model', model);
    if (mounted) setState(() => _geminiModel = model);
  }

  Future<void> _changeChatGPTApiKey(String apiKey) async {
    await widget.preferences?.setString('chatgpt_api_key', apiKey);
    if (mounted) setState(() => _chatGPTApiKey = apiKey);
  }

  Future<void> _changeChatGPTModel(String model) async {
    await widget.preferences?.setString('chatgpt_model', model);
    if (mounted) setState(() => _chatGPTModel = model);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.neutral.dark.touch;
    return MaterialApp(
      title: 'Transhelf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...FLocalizations.localizationsDelegates,
        flutter_l10n.GlobalMaterialLocalizations.delegate,
        flutter_l10n.GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
        Locale('en'),
      ],
      builder: (context, child) => FTheme(data: theme, child: child!),
      home: Scaffold(
        body: MainShell(
          locale: _locale,
          onLocaleChanged: _changeLocale,
          googleApiKey: _googleApiKey,
          onGoogleApiKeyChanged: _changeGoogleApiKey,
          geminiApiKey: _geminiApiKey,
          onGeminiApiKeyChanged: _changeGeminiApiKey,
          geminiModel: _geminiModel,
          onGeminiModelChanged: _changeGeminiModel,
          chatGPTApiKey: _chatGPTApiKey,
          onChatGPTApiKeyChanged: _changeChatGPTApiKey,
          chatGPTModel: _chatGPTModel,
          onChatGPTModelChanged: _changeChatGPTModel,
          articleStore: widget.articleStore,
          translationService: widget.translationService,
          geminiTranslationService: widget.geminiTranslationService,
          chatGPTTranslationService: widget.chatGPTTranslationService,
          preferences: widget.preferences,
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
    required this.googleApiKey,
    required this.onGoogleApiKeyChanged,
    required this.geminiApiKey,
    required this.onGeminiApiKeyChanged,
    required this.geminiModel,
    required this.onGeminiModelChanged,
    required this.chatGPTApiKey,
    required this.onChatGPTApiKeyChanged,
    required this.chatGPTModel,
    required this.onChatGPTModelChanged,
    this.articleStore,
    this.translationService,
    this.geminiTranslationService,
    this.chatGPTTranslationService,
    this.preferences,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final String googleApiKey;
  final Future<void> Function(String) onGoogleApiKeyChanged;
  final String geminiApiKey;
  final Future<void> Function(String) onGeminiApiKeyChanged;
  final String geminiModel;
  final Future<void> Function(String) onGeminiModelChanged;
  final String chatGPTApiKey;
  final Future<void> Function(String) onChatGPTApiKeyChanged;
  final String chatGPTModel;
  final Future<void> Function(String) onChatGPTModelChanged;
  final ArticleStore? articleStore;
  final GoogleTranslationService? translationService;
  final GeminiTranslationService? geminiTranslationService;
  final ChatGPTTranslationService? chatGPTTranslationService;
  final SharedPreferences? preferences;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late final ArticleStore _articleStore = widget.articleStore ?? ArticleStore();
  late final PresetStore _presetStore = PresetStore(widget.preferences);
  late final PrivatePinStore _privatePinStore = PrivatePinStore(
    widget.preferences,
  );
  List<Article> _articles = [];
  bool _showPrivateArticles = false;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      final articles = await _articleStore.load();
      if (mounted) {
        setState(() {
          final currentIds = _articles.map((article) => article.id).toSet();
          _articles = [
            ...articles.where((article) => !currentIds.contains(article.id)),
            ..._articles,
          ];
        });
      }
    } catch (_) {
      // The shelf remains available if local storage cannot be read.
    }
  }

  Future<void> _saveArticle(Article article) async {
    await _articleStore.save(article);
    if (mounted) setState(() => _articles = [..._articles, article]);
  }

  Future<void> _deleteArticle(Article article) async {
    await _articleStore.delete(article.id);
    if (mounted) {
      setState(
        () => _articles = _articles
            .where((item) => item.id != article.id)
            .toList(),
      );
    }
  }

  Future<void> _saveProgress(Article article, double progress) async {
    final latestArticle = _articles.firstWhere(
      (item) => item.id == article.id,
      orElse: () => article,
    );
    final updated = latestArticle.withProgress(progress);
    await _articleStore.save(updated);
    if (mounted) {
      setState(
        () => _articles = _articles
            .map((item) => item.id == updated.id ? updated : item)
            .toList(),
      );
    }
  }

  Future<void> _saveArticlePrivacy(Article article, bool isPrivate) async {
    final latestArticle = _articles.firstWhere(
      (item) => item.id == article.id,
      orElse: () => article,
    );
    final updated = latestArticle.withPrivacy(isPrivate);
    await _articleStore.save(updated);
    if (mounted) {
      setState(
        () => _articles = _articles
            .map((item) => item.id == updated.id ? updated : item)
            .toList(),
      );
    }
  }

  Future<void> _savePresetLibrary(PresetLibrarySnapshot library) async {
    await _presetStore.save(library);
  }

  Future<void> _openPresetManager() async {
    final library = await _presetStore.load();
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PresetListView(
          library: library,
          onLibraryChanged: _savePresetLibrary,
        ),
      ),
    );
  }

  void _openArticle(Article article) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReadingView(
          article: article,
          onProgress: (progress) => _saveProgress(article, progress),
          onPrivacyChanged: (isPrivate) =>
              _saveArticlePrivacy(article, isPrivate),
        ),
      ),
    );
  }

  Future<void> _setPrivateMode(bool showPrivate) async {
    if (!showPrivate) {
      setState(() => _showPrivateArticles = false);
      return;
    }
    if (!_privatePinStore.isConfigured) {
      final l10n = AppLocalizations.of(context)!;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          key: const ValueKey('private_pin_unconfigured_dialog'),
          title: Text(l10n.settingsPrivatePin),
          content: Text(l10n.privatePinUnconfigured),
          actions: [
            TextButton(
              key: const ValueKey('private_pin_go_to_settings'),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.privatePinGoToSettings),
            ),
          ],
        ),
      );
      if (mounted) {
        setState(() {
          _showPrivateArticles = false;
          _index = 2;
        });
      }
      return;
    }
    final unlocked = await _requestPrivatePin();
    if (unlocked && mounted) {
      setState(() => _showPrivateArticles = true);
    }
  }

  Future<bool> _requestPrivatePin() async {
    final l10n = AppLocalizations.of(context)!;
    var pin = '';
    var incorrect = false;
    var checking = false;
    var lockout = false;
    var cleanupFailed = false;

    Future<void> submit(StateSetter update, BuildContext dialogContext) async {
      if (pin.length != 4 || checking) return;
      update(() => checking = true);
      final result = await _privatePinStore.verify(pin);
      if (result == PinVerificationResult.correct) {
        if (dialogContext.mounted) Navigator.pop(dialogContext, true);
      } else if (result == PinVerificationResult.incorrect) {
        update(() {
          checking = false;
          incorrect = true;
          pin = '';
        });
      } else if (result == PinVerificationResult.limitReached) {
        lockout = true;
        try {
          await _handlePinLockout();
        } catch (_) {
          update(() {
            checking = false;
            cleanupFailed = true;
            pin = '';
          });
          return;
        }
        if (dialogContext.mounted) Navigator.pop(dialogContext, false);
      } else if (dialogContext.mounted) {
        Navigator.pop(dialogContext, false);
      }
    }

    void enterDigit(
      String digit,
      StateSetter update,
      BuildContext dialogContext,
    ) {
      if (checking || pin.length >= 4) return;
      update(() {
        pin += digit;
        incorrect = false;
        cleanupFailed = false;
      });
      if (pin.length == 4) submit(update, dialogContext);
    }

    final unlocked = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => Dialog(
          key: const ValueKey('private_pin_unlock_dialog'),
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: 340,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              border: Border.all(color: AppPalette.border),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    key: const ValueKey('private_pin_unlock_cancel'),
                    tooltip: l10n.privatePinClose,
                    onPressed: checking
                        ? null
                        : () => Navigator.pop(dialogContext, false),
                    icon: const Icon(FLucideIcons.x, size: 19),
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppPalette.surfaceRaised,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    FLucideIcons.lockKeyhole,
                    color: AppPalette.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  l10n.privatePinPromptTitle,
                  key: const ValueKey('private_pin_unlock_title'),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.privatePinPrompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppPalette.muted),
                ),
                const SizedBox(height: 17),
                Semantics(
                  key: const ValueKey('private_pin_unlock_dots'),
                  label: l10n.privatePinEnteredCount(pin.length),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        key: ValueKey('private_pin_dot_$index'),
                        width: 13,
                        height: 13,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pin.length > index
                              ? AppPalette.blue
                              : AppPalette.border,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (incorrect)
                  Text(
                    l10n.privatePinIncorrect,
                    key: const ValueKey('private_pin_unlock_error'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                if (cleanupFailed)
                  Text(
                    l10n.privatePinLockoutDeleteFailed,
                    key: const ValueKey('private_pin_cleanup_error'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                Text(
                  l10n.privatePinAttempts(
                    _privatePinStore.failedAttempts,
                    PrivatePinStore.failedAttemptLimit,
                  ),
                  key: const ValueKey('private_pin_unlock_attempts'),
                  style: const TextStyle(color: AppPalette.muted, fontSize: 11),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  key: const ValueKey('private_pin_keypad'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 7,
                  crossAxisSpacing: 7,
                  childAspectRatio: 1.55,
                  children: [
                    for (final digit in const [
                      '1',
                      '2',
                      '3',
                      '4',
                      '5',
                      '6',
                      '7',
                      '8',
                      '9',
                      '',
                      '0',
                      'back',
                    ])
                      if (digit.isEmpty)
                        const SizedBox.shrink()
                      else if (digit == 'back')
                        IconButton.filledTonal(
                          key: const ValueKey('private_pin_key_backspace'),
                          tooltip: l10n.privatePinDeleteDigit,
                          onPressed: checking
                              ? null
                              : () => update(() {
                                  if (pin.isNotEmpty) {
                                    pin = pin.substring(0, pin.length - 1);
                                  }
                                  incorrect = false;
                                  cleanupFailed = false;
                                }),
                          icon: const Icon(FLucideIcons.arrowLeft, size: 20),
                        )
                      else
                        FilledButton.tonal(
                          key: ValueKey('private_pin_key_$digit'),
                          onPressed: checking
                              ? null
                              : () => enterDigit(digit, update, dialogContext),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppPalette.surfaceRaised,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            digit,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (lockout && mounted) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          key: const ValueKey('private_pin_lockout_dialog'),
          content: Text(l10n.privatePinLockout),
          actions: [
            TextButton(
              key: const ValueKey('private_pin_lockout_dismiss'),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.articleCancel),
            ),
          ],
        ),
      );
    }
    return unlocked == true;
  }

  Future<void> _handlePinLockout() async {
    await _articleStore.deletePrivateArticles();
    await _privatePinStore.clearPin();
    if (mounted) {
      setState(() {
        _articles = _articles.where((article) => !article.isPrivate).toList();
        _showPrivateArticles = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FScaffold(
      scaffoldStyle: const .delta(backgroundColor: AppPalette.background),
      childPad: false,
      footer: FBottomNavigationBar(
        style: const .delta(
          decoration: .boxDelta(
            color: AppPalette.background,
            border: Border(top: BorderSide(color: AppPalette.border)),
          ),
        ),
        index: _index,
        onChange: (index) => setState(() {
          _index = index;
          _showPrivateArticles = false;
        }),
        children: [
          FBottomNavigationBarItem(
            key: const ValueKey('nav.translate'),
            icon: const Icon(FLucideIcons.languages),
            label: Text(l10n.navTranslate),
          ),
          FBottomNavigationBarItem(
            key: const ValueKey('nav.shelf'),
            icon: const Icon(FLucideIcons.bookOpen),
            label: Text(l10n.navShelf),
          ),
          FBottomNavigationBarItem(
            key: const ValueKey('nav.settings'),
            icon: const Icon(FLucideIcons.settings),
            label: Text(l10n.navSettings),
          ),
        ],
      ),
      child: IndexedStack(
        index: _index,
        children: [
          TranslateView(
            key: const ValueKey('view.translate'),
            apiKey: widget.googleApiKey,
            geminiApiKey: widget.geminiApiKey,
            geminiModel: widget.geminiModel,
            chatGPTApiKey: widget.chatGPTApiKey,
            chatGPTModel: widget.chatGPTModel,
            onOpenSettings: () => setState(() => _index = 2),
            onSaveArticle: _saveArticle,
            service: widget.translationService,
            geminiService: widget.geminiTranslationService,
            chatGPTService: widget.chatGPTTranslationService,
            preferences: widget.preferences,
          ),
          ShelfView(
            key: const ValueKey('view.shelf'),
            articles: _articles,
            showPrivateArticles: _showPrivateArticles,
            onPrivateModeChanged: _setPrivateMode,
            onOpen: _openArticle,
            onDelete: _deleteArticle,
          ),
          SettingView(
            key: const ValueKey('view.settings'),
            locale: widget.locale,
            onLocaleChanged: widget.onLocaleChanged,
            googleApiKey: widget.googleApiKey,
            onGoogleApiKeyChanged: widget.onGoogleApiKeyChanged,
            geminiApiKey: widget.geminiApiKey,
            onGeminiApiKeyChanged: widget.onGeminiApiKeyChanged,
            geminiModel: widget.geminiModel,
            onGeminiModelChanged: widget.onGeminiModelChanged,
            chatGPTApiKey: widget.chatGPTApiKey,
            onChatGPTApiKeyChanged: widget.onChatGPTApiKeyChanged,
            chatGPTModel: widget.chatGPTModel,
            onChatGPTModelChanged: widget.onChatGPTModelChanged,
            pinStore: _privatePinStore,
            pinConfigured: _privatePinStore.isConfigured,
            onPinSaved: () {
              if (mounted) setState(() {});
            },
            onPinLockout: _handlePinLockout,
            onOpenPresets: _openPresetManager,
          ),
        ],
      ),
    );
  }
}
