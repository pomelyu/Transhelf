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

  /// No description provided for @translateDismissKeyboard.
  ///
  /// In zh, this message translates to:
  /// **'收起鍵盤'**
  String get translateDismissKeyboard;

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

  /// No description provided for @readerPrivateArticle.
  ///
  /// In zh, this message translates to:
  /// **'私密文章'**
  String get readerPrivateArticle;

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

  /// No description provided for @shelfPrivateTag.
  ///
  /// In zh, this message translates to:
  /// **'私密'**
  String get shelfPrivateTag;

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

  /// No description provided for @settingsPrivatePin.
  ///
  /// In zh, this message translates to:
  /// **'私密文章 PIN'**
  String get settingsPrivatePin;

  /// No description provided for @privatePinSet.
  ///
  /// In zh, this message translates to:
  /// **'設定 PIN'**
  String get privatePinSet;

  /// No description provided for @privatePinChange.
  ///
  /// In zh, this message translates to:
  /// **'修改 PIN'**
  String get privatePinChange;

  /// No description provided for @privatePinConfigured.
  ///
  /// In zh, this message translates to:
  /// **'已設定'**
  String get privatePinConfigured;

  /// No description provided for @privatePinNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'尚未設定'**
  String get privatePinNotConfigured;

  /// No description provided for @privatePinStatusConfigured.
  ///
  /// In zh, this message translates to:
  /// **'已設定 PIN 碼'**
  String get privatePinStatusConfigured;

  /// No description provided for @privatePinStatusNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'未設定 PIN 碼'**
  String get privatePinStatusNotConfigured;

  /// No description provided for @privatePinCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get privatePinCancel;

  /// No description provided for @privatePinSave.
  ///
  /// In zh, this message translates to:
  /// **'儲存'**
  String get privatePinSave;

  /// No description provided for @privatePinCurrent.
  ///
  /// In zh, this message translates to:
  /// **'目前 PIN'**
  String get privatePinCurrent;

  /// No description provided for @privatePinNew.
  ///
  /// In zh, this message translates to:
  /// **'新 PIN'**
  String get privatePinNew;

  /// No description provided for @privatePinConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確認新 PIN'**
  String get privatePinConfirm;

  /// No description provided for @privatePinRequired.
  ///
  /// In zh, this message translates to:
  /// **'請輸入四位數 PIN。'**
  String get privatePinRequired;

  /// No description provided for @privatePinMismatch.
  ///
  /// In zh, this message translates to:
  /// **'兩次輸入的 PIN 不一致。'**
  String get privatePinMismatch;

  /// No description provided for @privatePinIncorrect.
  ///
  /// In zh, this message translates to:
  /// **'目前 PIN 錯誤。'**
  String get privatePinIncorrect;

  /// No description provided for @privatePinAttempts.
  ///
  /// In zh, this message translates to:
  /// **'錯誤次數：{count} / {limit}'**
  String privatePinAttempts(int count, int limit);

  /// No description provided for @privatePinSaved.
  ///
  /// In zh, this message translates to:
  /// **'PIN 已儲存。'**
  String get privatePinSaved;

  /// No description provided for @privatePinPrompt.
  ///
  /// In zh, this message translates to:
  /// **'請輸入 PIN 以顯示私密文章。'**
  String get privatePinPrompt;

  /// No description provided for @privatePinPromptTitle.
  ///
  /// In zh, this message translates to:
  /// **'解鎖私密文章'**
  String get privatePinPromptTitle;

  /// No description provided for @privatePinClose.
  ///
  /// In zh, this message translates to:
  /// **'關閉 PIN 輸入'**
  String get privatePinClose;

  /// No description provided for @privatePinDeleteDigit.
  ///
  /// In zh, this message translates to:
  /// **'刪除最後一位'**
  String get privatePinDeleteDigit;

  /// No description provided for @privatePinEnteredCount.
  ///
  /// In zh, this message translates to:
  /// **'已輸入 {count} / 4 位'**
  String privatePinEnteredCount(int count);

  /// No description provided for @privatePinGoToSettings.
  ///
  /// In zh, this message translates to:
  /// **'前往設定'**
  String get privatePinGoToSettings;

  /// No description provided for @privatePinUnconfigured.
  ///
  /// In zh, this message translates to:
  /// **'尚未設定 PIN，請先前往設定頁設定。'**
  String get privatePinUnconfigured;

  /// No description provided for @privatePinLockout.
  ///
  /// In zh, this message translates to:
  /// **'錯誤次數過多，已刪除所有私密文章並清除 PIN。'**
  String get privatePinLockout;

  /// No description provided for @privatePinLockoutDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'無法刪除所有私密文章，請再試一次。'**
  String get privatePinLockoutDeleteFailed;

  /// No description provided for @settingsComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'即將推出'**
  String get settingsComingSoon;

  /// No description provided for @presetManagementTitle.
  ///
  /// In zh, this message translates to:
  /// **'Preset 管理'**
  String get presetManagementTitle;

  /// No description provided for @presetNewTitle.
  ///
  /// In zh, this message translates to:
  /// **'新增 Preset'**
  String get presetNewTitle;

  /// No description provided for @presetEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'編輯 Preset'**
  String get presetEditTitle;

  /// No description provided for @presetDefault.
  ///
  /// In zh, this message translates to:
  /// **'預設'**
  String get presetDefault;

  /// No description provided for @presetFallbackName.
  ///
  /// In zh, this message translates to:
  /// **'預設翻譯'**
  String get presetFallbackName;

  /// No description provided for @presetSetDefault.
  ///
  /// In zh, this message translates to:
  /// **'設為預設'**
  String get presetSetDefault;

  /// No description provided for @presetCopy.
  ///
  /// In zh, this message translates to:
  /// **'複製 Preset'**
  String get presetCopy;

  /// No description provided for @presetName.
  ///
  /// In zh, this message translates to:
  /// **'名稱'**
  String get presetName;

  /// No description provided for @presetNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：學術論文'**
  String get presetNameHint;

  /// No description provided for @presetPrompt.
  ///
  /// In zh, this message translates to:
  /// **'自訂提示詞'**
  String get presetPrompt;

  /// No description provided for @presetPromptPreview.
  ///
  /// In zh, this message translates to:
  /// **'提示詞預覽'**
  String get presetPromptPreview;

  /// No description provided for @presetPromptHint.
  ///
  /// In zh, this message translates to:
  /// **'參考詞彙表翻譯文章，並保留專有名詞和人名。'**
  String get presetPromptHint;

  /// No description provided for @presetGlossary.
  ///
  /// In zh, this message translates to:
  /// **'自訂詞彙'**
  String get presetGlossary;

  /// No description provided for @presetAddTerm.
  ///
  /// In zh, this message translates to:
  /// **'新增詞彙'**
  String get presetAddTerm;

  /// No description provided for @presetEmptyGlossary.
  ///
  /// In zh, this message translates to:
  /// **'尚未新增詞彙'**
  String get presetEmptyGlossary;

  /// No description provided for @presetSourceTerm.
  ///
  /// In zh, this message translates to:
  /// **'原文詞彙'**
  String get presetSourceTerm;

  /// No description provided for @presetTargetTerm.
  ///
  /// In zh, this message translates to:
  /// **'譯文詞彙'**
  String get presetTargetTerm;

  /// No description provided for @presetCloseSelection.
  ///
  /// In zh, this message translates to:
  /// **'關閉'**
  String get presetCloseSelection;

  /// No description provided for @presetDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定刪除選取的項目？'**
  String get presetDeleteConfirm;

  /// No description provided for @presetSave.
  ///
  /// In zh, this message translates to:
  /// **'儲存 Preset'**
  String get presetSave;

  /// No description provided for @presetSaved.
  ///
  /// In zh, this message translates to:
  /// **'Preset 已儲存'**
  String get presetSaved;

  /// No description provided for @presetDeleted.
  ///
  /// In zh, this message translates to:
  /// **'Preset 已刪除'**
  String get presetDeleted;

  /// No description provided for @presetSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'無法儲存 Preset'**
  String get presetSaveFailed;

  /// No description provided for @presetDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'無法刪除 Preset'**
  String get presetDeleteFailed;

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

  /// No description provided for @translatorModelLabel.
  ///
  /// In zh, this message translates to:
  /// **'翻譯模型'**
  String get translatorModelLabel;

  /// No description provided for @translatorModelSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'無法儲存翻譯模型'**
  String get translatorModelSaveFailed;

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

  /// No description provided for @geminiConfigureFirst.
  ///
  /// In zh, this message translates to:
  /// **'請先設定 Gemini API key。'**
  String get geminiConfigureFirst;

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

  /// No description provided for @geminiTranslationFailed.
  ///
  /// In zh, this message translates to:
  /// **'Gemini 翻譯失敗'**
  String get geminiTranslationFailed;

  /// No description provided for @chatGPTConfigureFirst.
  ///
  /// In zh, this message translates to:
  /// **'請先設定 OpenAI API key。'**
  String get chatGPTConfigureFirst;

  /// No description provided for @chatGPTApiKeyInvalid.
  ///
  /// In zh, this message translates to:
  /// **'OpenAI API key 無效或未獲授權。'**
  String get chatGPTApiKeyInvalid;

  /// No description provided for @chatGPTTranslationFailed.
  ///
  /// In zh, this message translates to:
  /// **'ChatGPT 翻譯失敗'**
  String get chatGPTTranslationFailed;

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
