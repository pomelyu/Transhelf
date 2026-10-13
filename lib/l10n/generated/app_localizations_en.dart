// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navTranslate => 'Translate';

  @override
  String get navShelf => 'Articles';

  @override
  String get navSettings => 'Settings';

  @override
  String get translateEngine => 'Engine';

  @override
  String get translatePreset => 'Preset';

  @override
  String get translateSource => 'Source';

  @override
  String get translateResult => 'Translation';

  @override
  String get translateFromLanguage => 'English';

  @override
  String get translateToLanguage => 'Traditional Chinese';

  @override
  String get translatePresetName => 'Technical Writing';

  @override
  String get translateInputHint => 'Enter text to translate';

  @override
  String get translateOutputHint => 'Your translation will appear here';

  @override
  String get translateStart => 'Translate';

  @override
  String get translateSave => 'Save article';

  @override
  String get shelfSearchHint => 'Search articles';

  @override
  String get shelfSortRecent => 'Recently added';

  @override
  String get shelfShowPrivate => 'Show private';

  @override
  String get shelfEmptyTitle => 'No articles yet';

  @override
  String get shelfEmptyDescription =>
      'Translate and save an article to read it here.';

  @override
  String get settingsTagline =>
      'Translate, collect, and keep good reads close.';

  @override
  String get settingsTranslationSection => 'Translation';

  @override
  String get settingsTranslator => 'Translator settings';

  @override
  String get settingsTranslatorSubtitle => 'Services and API keys';

  @override
  String get settingsPresets => 'Preset management';

  @override
  String get settingsPresetsSubtitle => 'Organize translation prompts';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsAppLanguage => 'App language';

  @override
  String get settingsPrivacySection => 'Privacy';

  @override
  String get settingsAutosave => 'Save translations automatically';

  @override
  String get settingsPrivatePin => 'Private article PIN';

  @override
  String get settingsComingSoon => 'Coming soon';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';
}
