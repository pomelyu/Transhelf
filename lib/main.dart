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
import 'services/preset_store.dart';
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
  runApp(TranshelfApp(preferences: preferences, initialApiKey: apiKey));
}

class TranshelfApp extends StatefulWidget {
  const TranshelfApp({
    super.key,
    this.preferences,
    this.initialApiKey = '',
    this.articleStore,
    this.translationService,
  });

  final SharedPreferences? preferences;
  final String initialApiKey;
  final ArticleStore? articleStore;
  final GoogleTranslationService? translationService;

  @override
  State<TranshelfApp> createState() => _TranshelfAppState();
}

class _TranshelfAppState extends State<TranshelfApp> {
  late String _googleApiKey = widget.initialApiKey;
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
          articleStore: widget.articleStore,
          translationService: widget.translationService,
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
    this.articleStore,
    this.translationService,
    this.preferences,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final String googleApiKey;
  final Future<void> Function(String) onGoogleApiKeyChanged;
  final ArticleStore? articleStore;
  final GoogleTranslationService? translationService;
  final SharedPreferences? preferences;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late final ArticleStore _articleStore = widget.articleStore ?? ArticleStore();
  late final PresetStore _presetStore = PresetStore(widget.preferences);
  List<Article> _articles = [];

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
    final updated = article.withProgress(progress);
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReadingView(
          article: article,
          onProgress: (progress) => _saveProgress(article, progress),
        ),
      ),
    );
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
        onChange: (index) => setState(() => _index = index),
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
            onOpenSettings: () => setState(() => _index = 2),
            onSaveArticle: _saveArticle,
            service: widget.translationService,
          ),
          ShelfView(
            key: const ValueKey('view.shelf'),
            articles: _articles,
            onOpen: _openArticle,
            onDelete: _deleteArticle,
          ),
          SettingView(
            key: const ValueKey('view.settings'),
            locale: widget.locale,
            onLocaleChanged: widget.onLocaleChanged,
            googleApiKey: widget.googleApiKey,
            onGoogleApiKeyChanged: widget.onGoogleApiKeyChanged,
            onOpenPresets: _openPresetManager,
          ),
        ],
      ),
    );
  }
}
