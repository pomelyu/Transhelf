import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @navTranslate.
  ///
  /// In zh, this message translates to:
  /// **'翻譯'**
  String get navTranslate;

  /// No description provided for @navShelf.
  ///
  /// In zh, this message translates to:
  /// **'文章'**
  String get navShelf;

  /// No description provided for @navSettings.
  ///
  /// In zh, this message translates to:
  /// **'設定'**
  String get navSettings;

  /// No description provided for @translateEngine.
  ///
  /// In zh, this message translates to:
  /// **'引擎'**
  String get translateEngine;

  /// No description provided for @translatePreset.
  ///
  /// In zh, this message translates to:
  /// **'Preset'**
  String get translatePreset;

  /// No description provided for @translateSource.
  ///
  /// In zh, this message translates to:
  /// **'原文'**
  String get translateSource;

  /// No description provided for @translateResult.
  ///
  /// In zh, this message translates to:
  /// **'翻譯'**
  String get translateResult;

  /// No description provided for @translateFromLanguage.
  ///
  /// In zh, this message translates to:
  /// **'英文'**
  String get translateFromLanguage;

  /// No description provided for @translateToLanguage.
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get translateToLanguage;

  /// No description provided for @translatePresetName.
  ///
  /// In zh, this message translates to:
  /// **'技術文章'**
  String get translatePresetName;

  /// No description provided for @translateInputHint.
  ///
  /// In zh, this message translates to:
  /// **'輸入要翻譯的文字'**
  String get translateInputHint;

  /// No description provided for @translateOutputHint.
  ///
  /// In zh, this message translates to:
  /// **'翻譯結果會顯示於此'**
  String get translateOutputHint;

  /// No description provided for @translateStart.
  ///
  /// In zh, this message translates to:
  /// **'開始翻譯'**
  String get translateStart;

  /// No description provided for @translateSave.
  ///
  /// In zh, this message translates to:
  /// **'儲存文章'**
  String get translateSave;

  /// No description provided for @translateCharacters.
  ///
  /// In zh, this message translates to:
  /// **'字元'**
  String get translateCharacters;

  /// No description provided for @translateClearSource.
  ///
  /// In zh, this message translates to:
  /// **'清除原文'**
  String get translateClearSource;

  /// No description provided for @translateCopy.
  ///
  /// In zh, this message translates to:
  /// **'複製翻譯'**
  String get translateCopy;

  /// No description provided for @translateCopied.
  ///
  /// In zh, this message translates to:
  /// **'已複製翻譯'**
  String get translateCopied;

  /// No description provided for @translateAgain.
  ///
  /// In zh, this message translates to:
  /// **'重新翻譯'**
  String get translateAgain;

  /// No description provided for @translateEdit.
  ///
  /// In zh, this message translates to:
  /// **'編輯譯文'**
  String get translateEdit;

  /// No description provided for @translateFinishEditing.
  ///
  /// In zh, this message translates to:
  /// **'完成編輯'**
  String get translateFinishEditing;

  /// No description provided for @articleTitle.
  ///
  /// In zh, this message translates to:
  /// **'文章標題'**
  String get articleTitle;

  /// No description provided for @articleTitleHint.
  ///
  /// In zh, this message translates to:
  /// **'請輸入文章標題'**
  String get articleTitleHint;

  /// No description provided for @articleSaveToShelf.
  ///
  /// In zh, this message translates to:
  /// **'儲存至書架'**
  String get articleSaveToShelf;

  /// No description provided for @articleSaved.
  ///
  /// In zh, this message translates to:
  /// **'文章已儲存至書架'**
  String get articleSaved;

  /// No description provided for @articleSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'無法儲存文章'**
  String get articleSaveFailed;

  /// No description provided for @articleDelete.
  ///
  /// In zh, this message translates to:
  /// **'刪除'**
  String get articleDelete;

  /// No description provided for @articleDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定刪除這篇文章？'**
  String get articleDeleteConfirm;

  /// No description provided for @articleDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'無法刪除文章'**
  String get articleDeleteFailed;

  /// No description provided for @articleCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get articleCancel;

  /// No description provided for @articleNoResults.
  ///
  /// In zh, this message translates to:
  /// **'沒有符合的文章'**
  String get articleNoResults;

  /// No description provided for @articleReadPercent.
  ///
  /// In zh, this message translates to:
  /// **'已閱讀 {percent}%'**
  String articleReadPercent(int percent);

  /// No description provided for @shelfSortOldest.
  ///
  /// In zh, this message translates to:
  /// **'最早加入'**
  String get shelfSortOldest;

  /// No description provided for @shelfSortProgress.
  ///
  /// In zh, this message translates to:
  /// **'閱讀進度'**
  String get shelfSortProgress;

  /// No description provided for @shelfSortTitle.
  ///
  /// In zh, this message translates to:
  /// **'標題'**
  String get shelfSortTitle;

  /// No description provided for @readerBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get readerBack;

  /// No description provided for @readerSettings.
  ///
  /// In zh, this message translates to:
  /// **'閱讀設定'**
  String get readerSettings;

  /// No description provided for @readerTranslation.
  ///
  /// In zh, this message translates to:
  /// **'譯文'**
  String get readerTranslation;

  /// No description provided for @readerSource.
  ///
  /// In zh, this message translates to:
  /// **'原文'**
  String get readerSource;

  /// No description provided for @readerBoth.
  ///
  /// In zh, this message translates to:
  /// **'對照'**
  String get readerBoth;

  /// No description provided for @readerTextSize.
  ///
  /// In zh, this message translates to:
  /// **'文字大小'**
  String get readerTextSize;

  /// No description provided for @readerSmall.
  ///
  /// In zh, this message translates to:
  /// **'小'**
  String get readerSmall;

  /// No description provided for @readerMedium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get readerMedium;

  /// No description provided for @readerLarge.
  ///
  /// In zh, this message translates to:
  /// **'大'**
  String get readerLarge;

  /// No description provided for @readerRelaxedSpacing.
  ///
  /// In zh, this message translates to:
  /// **'寬鬆行距'**
  String get readerRelaxedSpacing;

  /// No description provided for @shelfSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜尋文章'**
  String get shelfSearchHint;

  /// No description provided for @shelfSortRecent.
  ///
  /// In zh, this message translates to:
  /// **'最近加入'**
  String get shelfSortRecent;

  /// No description provided for @shelfShowPrivate.
  ///
  /// In zh, this message translates to:
  /// **'顯示私密'**
  String get shelfShowPrivate;

  /// No description provided for @shelfEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'還沒有文章'**
  String get shelfEmptyTitle;

  /// No description provided for @shelfEmptyDescription.
  ///
  /// In zh, this message translates to:
  /// **'翻譯並儲存文章後，就能在這裡閱讀。'**
  String get shelfEmptyDescription;

  /// No description provided for @settingsTagline.
  ///
  /// In zh, this message translates to:
  /// **'翻譯 × 書架，把好的內容留在手邊。'**
  String get settingsTagline;

  /// No description provided for @settingsTranslationSection.
  ///
  /// In zh, this message translates to:
  /// **'翻譯'**
  String get settingsTranslationSection;

  /// No description provided for @settingsTranslator.
  ///
  /// In zh, this message translates to:
  /// **'Translator 設定'**
  String get settingsTranslator;

  /// No description provided for @settingsTranslatorSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'設定翻譯服務與 API Key'**
  String get settingsTranslatorSubtitle;

  /// No description provided for @settingsPresets.
  ///
  /// In zh, this message translates to:
  /// **'Preset 管理'**
  String get settingsPresets;

  /// No description provided for @settingsPresetsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'建立並整理翻譯提示'**
  String get settingsPresetsSubtitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In zh, this message translates to:
  /// **'語言'**
  String get settingsLanguageSection;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In zh, this message translates to:
  /// **'介面語言'**
  String get settingsAppLanguage;

  /// No description provided for @settingsPrivacySection.
  ///
  /// In zh, this message translates to:
  /// **'隱私'**
  String get settingsPrivacySection;

  /// No description provided for @settingsAutosave.
  ///
  /// In zh, this message translates to:
  /// **'自動儲存翻譯'**
  String get settingsAutosave;

  /// No description provided for @settingsPrivatePin.
  ///
  /// In zh, this message translates to:
  /// **'私密文章 PIN'**
  String get settingsPrivatePin;

  /// No description provided for @settingsComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'即將推出'**
  String get settingsComingSoon;

  /// No description provided for @languageTraditionalChinese.
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get languageTraditionalChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @googleTranslateName.
  ///
  /// In zh, this message translates to:
  /// **'Google 翻譯'**
  String get googleTranslateName;

  /// No description provided for @googleConfigured.
  ///
  /// In zh, this message translates to:
  /// **'已設定'**
  String get googleConfigured;

  /// No description provided for @googleNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'尚未設定'**
  String get googleNotConfigured;

  /// No description provided for @googlePending.
  ///
  /// In zh, this message translates to:
  /// **'待設定'**
  String get googlePending;

  /// No description provided for @googleApiKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'請輸入 API key'**
  String get googleApiKeyHint;

  /// No description provided for @googleApiKeySaved.
  ///
  /// In zh, this message translates to:
  /// **'API key 已儲存'**
  String get googleApiKeySaved;

  /// No description provided for @googleApiKeySaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'無法儲存 API key'**
  String get googleApiKeySaveFailed;

  /// No description provided for @googleShowApiKey.
  ///
  /// In zh, this message translates to:
  /// **'顯示 API key'**
  String get googleShowApiKey;

  /// No description provided for @googleHideApiKey.
  ///
  /// In zh, this message translates to:
  /// **'隱藏 API key'**
  String get googleHideApiKey;

  /// No description provided for @googleEditApiKey.
  ///
  /// In zh, this message translates to:
  /// **'編輯 API key'**
  String get googleEditApiKey;

  /// No description provided for @googleServiceTip.
  ///
  /// In zh, this message translates to:
  /// **'Google 翻譯會自動偵測來源語言，適合快速處理短句與一般內容。'**
  String get googleServiceTip;

  /// No description provided for @googleSaveSettings.
  ///
  /// In zh, this message translates to:
  /// **'儲存設定'**
  String get googleSaveSettings;

  /// No description provided for @googlePresetUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'不支援'**
  String get googlePresetUnavailable;

  /// No description provided for @googleDetectLanguage.
  ///
  /// In zh, this message translates to:
  /// **'自動偵測'**
  String get googleDetectLanguage;

  /// No description provided for @googleJapanese.
  ///
  /// In zh, this message translates to:
  /// **'日文'**
  String get googleJapanese;

  /// No description provided for @googleKorean.
  ///
  /// In zh, this message translates to:
  /// **'韓文'**
  String get googleKorean;

  /// No description provided for @googleEnterText.
  ///
  /// In zh, this message translates to:
  /// **'請輸入要翻譯的文字。'**
  String get googleEnterText;

  /// No description provided for @googleConfigureFirst.
  ///
  /// In zh, this message translates to:
  /// **'請先設定 Google 翻譯 API key。'**
  String get googleConfigureFirst;

  /// No description provided for @googleApiKeyInvalid.
  ///
  /// In zh, this message translates to:
  /// **'API key 無效或未獲授權，請到設定更新。'**
  String get googleApiKeyInvalid;

  /// No description provided for @googleTranslationFailed.
  ///
  /// In zh, this message translates to:
  /// **'翻譯失敗'**
  String get googleTranslationFailed;

  /// No description provided for @googleOpenSettings.
  ///
  /// In zh, this message translates to:
  /// **'前往設定'**
  String get googleOpenSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
