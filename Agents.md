# Transhelf
Transhelf 是一個翻譯的手機應用，它可以將使用者輸入的文字，配合客製化的翻譯提示，交給網路服務翻譯。並提供將翻譯結果的儲存管理功能。
以下是他的主要特色：
1. 支援多語言的介面
2. 提供 Google 翻譯和 LLM 模型翻譯
3. 提供客製化 preset 用於 LLM 翻譯。preset 包含翻譯提示的 prompt 指示和指定翻譯的單字簿
4. 支援長文章(10000+)的翻譯與瀏覽
5. 提供 preset 的管理
6. 可以儲存翻譯結果成為文章，並提供文章的檔案管理
7. 提供私密的選項，以隱藏被標記的文章於管理頁面，並輸入PIN碼後顯示
8. 提供文章的閱讀器，可以調整字體大小與行間距
9. 提供設定頁面，可以設定翻譯服務的 API key 和「私密」的解鎖 PIN 碼
10. app 會保持設定和儲存的 preset 與文章，以供下次開啟使用

## 主要頁面
主要頁面藉著底下的 Navigation Bar 切換
1. TranslateView - 翻譯的主介面：提供翻譯服務、語言、preset 的選擇。顯示翻譯結果、提供儲存的按鈕
2. ShelfView - 文章的管理介面：提供文章檔案的刪除、開啟、排序、標題搜尋功能。並可以切換顯示「私密」檔案 
3. SettingView - 設定介面：提供翻譯服務、Preset管理、語言和 PIN 碼的設定

## 次要介面
次要介面從主要介面或是其他次要介面進入，都提供返回來源介面的功能
1. ReadingView - 閱讀器介面：由 ShelfView 點擊文章後開啟。提供文章閱讀、字體大小、行距切換和顯示閱讀進度的功能
2. ServiceView - 翻譯服務的設定介面：由 SettingView 點擊進入。提供各個服務的模型選擇和API Key設定
3. PresetListView - Preset的管理介面：由 SettingView 點擊進入。提供 Preset 的新增、刪除、進入編輯介面的功能
4. PresetEditView - Preset的編輯介面：由 PresetListView 點擊新增或是編輯進入。提供 Preset 名稱、prompt、單字簿設定的功能

# Tech Stack
- 使用 Dart + Flutter 開發，UI 框架用 Forui

