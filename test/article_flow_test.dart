import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transhelf/main.dart';
import 'package:transhelf/models/article.dart';
import 'package:transhelf/services/article_store.dart';
import 'package:transhelf/services/google_translation_service.dart';

void main() {
  testWidgets('translated article can be saved, opened, and deleted', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = _MemoryArticleStore();
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = GoogleTranslationService(
      post: (_, _) async => (
        200,
        jsonEncode({
          'data': {
            'translations': [
              {'translatedText': '這是譯文。'},
            ],
          },
        }),
      ),
    );

    await tester.pumpWidget(
      TranshelfApp(
        preferences: preferences,
        initialApiKey: 'test-key',
        articleStore: store,
        translationService: service,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('translate_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('translate_error')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('translate_input')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('translate_error')), findsNothing);
    expect(find.byKey(const ValueKey('engine_dropdown')), findsNothing);
    expect(find.byKey(const ValueKey('translate_source_tab')), findsNothing);
    expect(
      find.byKey(const ValueKey('dismiss_translate_keyboard_button')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('dismiss_translate_keyboard_button')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('engine_dropdown')), findsOneWidget);
    expect(find.byKey(const ValueKey('translate_source_tab')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('translate_input')),
      'This sentence has enough letters.',
    );
    expect(find.byKey(const ValueKey('save_article_button')), findsNothing);
    tester.testTextInput.hide();
    await tester.tap(find.byKey(const ValueKey('translate_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('translate_button')), findsNothing);
    expect(find.byKey(const ValueKey('save_article_button')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('translate_output')))
          .readOnly,
      isTrue,
    );
    await tester.tap(find.byKey(const ValueKey('edit_translation_button')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('translate_output')))
          .readOnly,
      isFalse,
    );
    await tester.enterText(
      find.byKey(const ValueKey('translate_output')),
      '手動修訂的譯文。',
    );
    tester.testTextInput.hide();
    await tester.tap(find.byKey(const ValueKey('edit_translation_button')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('translate_output')))
          .readOnly,
      isTrue,
    );
    await tester.tap(find.byKey(const ValueKey('save_article_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('article_title_input')),
      'Sample Article',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('article_save_confirm')));
    await tester.pumpAndSettle();

    final input = find.byKey(const ValueKey('translate_input'));
    expect(input, findsOneWidget);
    expect(tester.widget<TextField>(input).controller!.text, isEmpty);
    expect(find.byKey(const ValueKey('save_article_button')), findsNothing);
    expect(find.byKey(const ValueKey('translate_button')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('translate_result_tab')));
    await tester.pumpAndSettle();
    final output = find.byKey(const ValueKey('translate_output'));
    expect(tester.widget<TextField>(output).controller!.text, isEmpty);
    await tester.tap(find.byKey(const ValueKey('translate_source_tab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('translate_input')), findsOneWidget);

    final articles = await store.load();
    expect(articles, hasLength(1));
    expect(
      articles.single.segments.single.source,
      'This sentence has enough letters.',
    );
    expect(articles.single.segments.single.translation, '手動修訂的譯文。');
    expect(articles.single.isPrivate, isFalse);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav.shelf')));
    await tester.pumpAndSettle();
    final card = find.byKey(ValueKey('article_${articles.single.id}'));
    expect(card, findsOneWidget);
    await tester.tap(
      find.descendant(of: card, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reader_content')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('reader_settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reader_spacing')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('reader_back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reader_content')), findsNothing);

    await tester.tap(
      find.byKey(ValueKey('article_menu_${articles.single.id}')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuItem<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('article_delete_confirm')));
    await tester.pumpAndSettle();
    expect(await store.load(), isEmpty);
  });

  testWidgets('clearing source resets the translated action state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    var requests = 0;
    final service = GoogleTranslationService(
      post: (_, _) async {
        requests++;
        return (
          200,
          jsonEncode({
            'data': {
              'translations': [
                {'translatedText': '這是譯文。'},
              ],
            },
          }),
        );
      },
    );
    await tester.pumpWidget(
      TranshelfApp(
        preferences: preferences,
        initialApiKey: 'test-key',
        articleStore: _MemoryArticleStore(),
        translationService: service,
      ),
    );
    await tester.enterText(
      find.byKey(const ValueKey('translate_input')),
      'This sentence has enough letters.',
    );
    tester.testTextInput.hide();
    await tester.tap(find.byKey(const ValueKey('translate_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('retranslate_button')));
    await tester.pumpAndSettle();
    expect(requests, 2);
    await tester.tap(find.text('原文').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('save_article_button')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('clear_source_button')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('translate_input')))
          .controller!
          .text,
      isEmpty,
    );
    expect(find.byKey(const ValueKey('save_article_button')), findsNothing);
    expect(find.byKey(const ValueKey('translate_button')), findsOneWidget);
  });

  testWidgets('reader saves scroll progress when returning to shelf', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = _MemoryArticleStore();
    await store.save(
      Article(
        id: 'long_article',
        title: 'Long article',
        createdAt: DateTime.utc(2026, 10, 14),
        sourceLanguage: 'en',
        targetLanguage: 'zh-TW',
        service: 'google',
        segments: List.generate(
          30,
          (_) => const ArticleSegment(
            source: 'This is a source paragraph with enough words to fill several lines. This is another sentence.',
            translation: '這是一段足以填滿數行的翻譯內容。這是另一個句子。',
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      TranshelfApp(preferences: preferences, articleStore: store),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav.shelf')));
    await tester.pumpAndSettle();
    final card = find.byKey(const ValueKey('article_long_article'));
    await tester.tap(
      find.descendant(of: card, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('reader_content')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reader_back')));
    await tester.pumpAndSettle();
    expect((await store.load()).single.progress, greaterThan(0));
  });
}

class _MemoryArticleStore extends ArticleStore {
  final Map<String, Article> _articles = {};

  @override
  Future<List<Article>> load() async => _articles.values.toList();

  @override
  Future<void> save(Article article) async {
    _articles[article.id] = article;
  }

  @override
  Future<void> delete(String id) async {
    _articles.remove(id);
  }
}
