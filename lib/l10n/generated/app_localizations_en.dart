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

  @override
  String get googleTranslateName => 'Google Translate';

  @override
  String get googleConfigured => 'Configured';

  @override
  String get googleNotConfigured => 'Not set';

  @override
  String get googlePending => 'Pending';

  @override
  String get googleApiKeyHint => 'Enter API key';

  @override
  String get googleApiKeySaved => 'API key saved';

  @override
  String get googleApiKeySaveFailed => 'Could not save API key';

  @override
  String get googleShowApiKey => 'Show API key';

  @override
  String get googleHideApiKey => 'Hide API key';

  @override
  String get googleEditApiKey => 'Edit API key';

  @override
  String get googleServiceTip =>
      'Google Translate detects the source language automatically and works well for general text.';

  @override
  String get googleSaveSettings => 'Save settings';

  @override
  String get googlePresetUnavailable => 'Not supported';

  @override
  String get googleDetectLanguage => 'Detect language';

  @override
  String get googleJapanese => 'Japanese';

  @override
  String get googleKorean => 'Korean';

  @override
  String get googleEnterText => 'Enter text to translate.';

  @override
  String get googleConfigureFirst => 'Set your Google Translate API key first.';

  @override
  String get googleApiKeyInvalid =>
      'API key is invalid or unauthorized. Update it in Settings.';

  @override
  String get googleTranslationFailed => 'Translation failed';

  @override
  String get googleOpenSettings => 'Open settings';
}
