// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navTranslate => '翻譯';

  @override
  String get navShelf => '文章';

  @override
  String get navSettings => '設定';

  @override
  String get translateEngine => '引擎';

  @override
  String get translatePreset => 'Preset';

  @override
  String get translateSource => '原文';

  @override
  String get translateResult => '翻譯';

  @override
  String get translateFromLanguage => '英文';

  @override
  String get translateToLanguage => '繁體中文';

  @override
  String get translatePresetName => '技術文章';

  @override
  String get translateInputHint => '輸入要翻譯的文字';

  @override
  String get translateOutputHint => '翻譯結果會顯示於此';

  @override
  String get translateStart => '開始翻譯';

  @override
  String get translateSave => '儲存文章';

  @override
  String get shelfSearchHint => '搜尋文章';

  @override
  String get shelfSortRecent => '最近加入';

  @override
  String get shelfShowPrivate => '顯示私密';

  @override
  String get shelfEmptyTitle => '還沒有文章';

  @override
  String get shelfEmptyDescription => '翻譯並儲存文章後，就能在這裡閱讀。';

  @override
  String get settingsTagline => '翻譯 × 書架，把好的內容留在手邊。';

  @override
  String get settingsTranslationSection => '翻譯';

  @override
  String get settingsTranslator => 'Translator 設定';

  @override
  String get settingsTranslatorSubtitle => '設定翻譯服務與 API Key';

  @override
  String get settingsPresets => 'Preset 管理';

  @override
  String get settingsPresetsSubtitle => '建立並整理翻譯提示';

  @override
  String get settingsLanguageSection => '語言';

  @override
  String get settingsAppLanguage => '介面語言';

  @override
  String get settingsPrivacySection => '隱私';

  @override
  String get settingsAutosave => '自動儲存翻譯';

  @override
  String get settingsPrivatePin => '私密文章 PIN';

  @override
  String get settingsComingSoon => '即將推出';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';
}
