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
  String get translateInputHint => '輸入要翻譯的文字';

  @override
  String get translateOutputHint => '翻譯結果會顯示於此';

  @override
  String get translateStart => '開始翻譯';

  @override
  String get translateSave => '儲存文章';

  @override
  String get translateCharacters => '字元';

  @override
  String get translateClearSource => '清除原文';

  @override
  String get translateDismissKeyboard => '收起鍵盤';

  @override
  String get translateCopy => '複製翻譯';

  @override
  String get translateCopied => '已複製翻譯';

  @override
  String get translateAgain => '重新翻譯';

  @override
  String get translateEdit => '編輯譯文';

  @override
  String get translateFinishEditing => '完成編輯';

  @override
  String get articleTitle => '文章標題';

  @override
  String get articleTitleHint => '請輸入文章標題';

  @override
  String get articleSaveToShelf => '儲存至書架';

  @override
  String get articleSaved => '文章已儲存至書架';

  @override
  String get articleSaveFailed => '無法儲存文章';

  @override
  String get articleDelete => '刪除';

  @override
  String get articleDeleteConfirm => '確定刪除這篇文章？';

  @override
  String get articleDeleted => '文章已刪除';

  @override
  String get articleDeleteFailed => '無法刪除文章';

  @override
  String get articleCancel => '取消';

  @override
  String get articleNoResults => '沒有符合的文章';

  @override
  String articleReadPercent(int percent) {
    return '已閱讀 $percent%';
  }

  @override
  String get shelfSortOldest => '最早加入';

  @override
  String get shelfSortProgress => '閱讀進度';

  @override
  String get shelfSortTitle => '標題';

  @override
  String get readerBack => '返回';

  @override
  String get readerSettings => '閱讀設定';

  @override
  String get readerTranslation => '譯文';

  @override
  String get readerSource => '原文';

  @override
  String get readerBoth => '對照';

  @override
  String get readerTextSize => '文字大小';

  @override
  String get readerSmall => '小';

  @override
  String get readerMedium => '中';

  @override
  String get readerLarge => '大';

  @override
  String get readerRelaxedSpacing => '寬鬆行距';

  @override
  String get readerPrivateArticle => '私密文章';

  @override
  String get shelfSearchHint => '搜尋文章';

  @override
  String get shelfSortRecent => '最近加入';

  @override
  String get shelfShowPrivate => '顯示私密';

  @override
  String get shelfPrivateTag => '私密';

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
  String get settingsPrivatePin => '私密文章 PIN';

  @override
  String get privatePinSet => '設定 PIN';

  @override
  String get privatePinChange => '修改 PIN';

  @override
  String get privatePinConfigured => '已設定';

  @override
  String get privatePinNotConfigured => '尚未設定';

  @override
  String get privatePinStatusConfigured => '已設定 PIN 碼';

  @override
  String get privatePinStatusNotConfigured => '未設定 PIN 碼';

  @override
  String get privatePinCancel => '取消';

  @override
  String get privatePinSave => '儲存';

  @override
  String get privatePinCurrent => '目前 PIN';

  @override
  String get privatePinNew => '新 PIN';

  @override
  String get privatePinConfirm => '確認新 PIN';

  @override
  String get privatePinRequired => '請輸入四位數 PIN。';

  @override
  String get privatePinMismatch => '兩次輸入的 PIN 不一致。';

  @override
  String get privatePinIncorrect => '目前 PIN 錯誤。';

  @override
  String privatePinAttempts(int count, int limit) {
    return '錯誤次數：$count / $limit';
  }

  @override
  String get privatePinSaved => 'PIN 已儲存。';

  @override
  String get privatePinPrompt => '請輸入 PIN 以顯示私密文章。';

  @override
  String get privatePinPromptTitle => '解鎖私密文章';

  @override
  String get privatePinClose => '關閉 PIN 輸入';

  @override
  String get privatePinDeleteDigit => '刪除最後一位';

  @override
  String privatePinEnteredCount(int count) {
    return '已輸入 $count / 4 位';
  }

  @override
  String get privatePinGoToSettings => '前往設定';

  @override
  String get privatePinUnconfigured => '尚未設定 PIN，請先前往設定頁設定。';

  @override
  String get privatePinLockout => '錯誤次數過多，已刪除所有私密文章並清除 PIN。';

  @override
  String get privatePinLockoutDeleteFailed => '無法刪除所有私密文章，請再試一次。';

  @override
  String get settingsComingSoon => '即將推出';

  @override
  String get presetManagementTitle => 'Preset 管理';

  @override
  String get presetNewTitle => '新增 Preset';

  @override
  String get presetEditTitle => '編輯 Preset';

  @override
  String get presetDefault => '預設';

  @override
  String get presetFallbackName => '預設翻譯';

  @override
  String get presetSetDefault => '設為預設';

  @override
  String get presetCopy => '複製 Preset';

  @override
  String get presetName => '名稱';

  @override
  String get presetNameHint => '例如：學術論文';

  @override
  String get presetPrompt => '自訂提示詞';

  @override
  String get presetLlmSegmentation => 'LLM 分段';

  @override
  String get presetPromptPreview => '提示詞預覽';

  @override
  String get presetPromptHint => '參考詞彙表翻譯文章，並保留專有名詞和人名。';

  @override
  String get presetGlossary => '自訂詞彙';

  @override
  String get presetAddTerm => '新增詞彙';

  @override
  String get presetEmptyGlossary => '尚未新增詞彙';

  @override
  String get presetSourceTerm => '原文詞彙';

  @override
  String get presetTargetTerm => '譯文詞彙';

  @override
  String get presetCloseSelection => '關閉';

  @override
  String get presetDeleteConfirm => '確定刪除選取的項目？';

  @override
  String get presetSave => '儲存 Preset';

  @override
  String get presetSaved => 'Preset 已儲存';

  @override
  String get presetDeleted => 'Preset 已刪除';

  @override
  String get presetSaveFailed => '無法儲存 Preset';

  @override
  String get presetDeleteFailed => '無法刪除 Preset';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get googleTranslateName => 'Google 翻譯';

  @override
  String get googleConfigured => '已設定';

  @override
  String get googleNotConfigured => '尚未設定';

  @override
  String get googlePending => '待設定';

  @override
  String get googleApiKeyHint => '請輸入 API key';

  @override
  String get googleApiKeySaved => 'API key 已儲存';

  @override
  String get translatorModelLabel => '翻譯模型';

  @override
  String get translatorModelSaveFailed => '無法儲存翻譯模型';

  @override
  String get googleApiKeySaveFailed => '無法儲存 API key';

  @override
  String get googleShowApiKey => '顯示 API key';

  @override
  String get googleHideApiKey => '隱藏 API key';

  @override
  String get googleEditApiKey => '編輯 API key';

  @override
  String get googleServiceTip => 'Google 翻譯會自動偵測來源語言，適合快速處理短句與一般內容。';

  @override
  String get googleSaveSettings => '儲存設定';

  @override
  String get googlePresetUnavailable => '不支援';

  @override
  String get googleDetectLanguage => '自動偵測';

  @override
  String get googleJapanese => '日文';

  @override
  String get googleKorean => '韓文';

  @override
  String get googleEnterText => '請輸入要翻譯的文字。';

  @override
  String get googleConfigureFirst => '請先設定 Google 翻譯 API key。';

  @override
  String get geminiConfigureFirst => '請先設定 Gemini API key。';

  @override
  String get googleApiKeyInvalid => 'API key 無效或未獲授權，請到設定更新。';

  @override
  String get googleTranslationFailed => '翻譯失敗';

  @override
  String get geminiTranslationFailed => 'Gemini 翻譯失敗';

  @override
  String get chatGPTConfigureFirst => '請先設定 OpenAI API key。';

  @override
  String get chatGPTApiKeyInvalid => 'OpenAI API key 無效或未獲授權。';

  @override
  String get chatGPTTranslationFailed => 'ChatGPT 翻譯失敗';

  @override
  String get translateLlmSegmentationInvalid =>
      'LLM 分段回應格式無效，請重試或關閉「LLM 分段」後再翻譯。';

  @override
  String translateLlmSegmentationFailed(Object error) {
    return 'LLM 分段翻譯失敗：$error';
  }

  @override
  String get translateLlmSegmentationRequestFailed =>
      'LLM 分段翻譯請求失敗，請稍後再試或關閉「LLM 分段」後重試。';

  @override
  String get googleOpenSettings => '前往設定';
}
