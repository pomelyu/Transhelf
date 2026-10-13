import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_l10n;
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/generated/app_localizations.dart';
import 'ui/app_palette.dart';
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
  const TranshelfApp({super.key, this.preferences, this.initialApiKey = ''});

  final SharedPreferences? preferences;
  final String initialApiKey;

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
      home: MainShell(
        locale: _locale,
        onLocaleChanged: _changeLocale,
        googleApiKey: _googleApiKey,
        onGoogleApiKeyChanged: _changeGoogleApiKey,
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
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final String googleApiKey;
  final Future<void> Function(String) onGoogleApiKeyChanged;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

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
          ),
          const ShelfView(key: ValueKey('view.shelf')),
          SettingView(
            key: const ValueKey('view.settings'),
            locale: widget.locale,
            onLocaleChanged: widget.onLocaleChanged,
            googleApiKey: widget.googleApiKey,
            onGoogleApiKeyChanged: widget.onGoogleApiKeyChanged,
          ),
        ],
      ),
    );
  }
}
