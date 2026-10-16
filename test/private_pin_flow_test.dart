import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transhelf/main.dart';
import 'package:transhelf/models/article.dart';
import 'package:transhelf/services/article_store.dart';
import 'package:transhelf/services/private_pin_store.dart';

void main() {
  testWidgets(
    'private articles require a PIN and lock when leaving ShelfView',
    (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'private_article_pin': '4826'});
      final preferences = await SharedPreferences.getInstance();
      final store = _MemoryArticleStore()
        ..saveSync(_article('public_article', false))
        ..saveSync(_article('private_article', true));
      await tester.pumpWidget(
        TranshelfApp(preferences: preferences, articleStore: store),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nav.shelf')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('article_public_article')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('article_private_article')),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('shelf_private_toggle')));
      await tester.pumpAndSettle();
      await _enterPin(tester, '0000');

      expect(
        find.byKey(const ValueKey('private_pin_unlock_error')),
        findsOneWidget,
      );
      expect(preferences.getInt('private_pin_failed_attempts'), 1);
      await _enterPin(tester, '4826');
      expect(
        find.byKey(const ValueKey('article_private_article')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('article_public_article')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('nav.settings')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nav.shelf')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('article_private_article')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('article_public_article')),
        findsOneWidget,
      );
    },
  );

  testWidgets('missing PIN prompts navigation to settings', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      TranshelfApp(
        preferences: preferences,
        articleStore: _MemoryArticleStore(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav.shelf')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('shelf_private_toggle')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('private_pin_unconfigured_dialog')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('private_pin_go_to_settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('view.settings')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('private_pin_settings')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('private_pin_settings_view')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('private_pin_status_card')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('private_pin_edit')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('private_pin_new_input')),
      '4826',
    );
    await tester.enterText(
      find.byKey(const ValueKey('private_pin_confirm_input')),
      '4826',
    );
    tester.testTextInput.hide();
    await tester.tap(find.byKey(const ValueKey('private_pin_save')));
    await tester.pumpAndSettle();
    expect(preferences.getString('private_article_pin'), '4826');

    await tester.tap(find.byKey(const ValueKey('private_pin_edit')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('private_pin_current_input')),
      '0000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('private_pin_new_input')),
      '1937',
    );
    await tester.enterText(
      find.byKey(const ValueKey('private_pin_confirm_input')),
      '1937',
    );
    tester.testTextInput.hide();
    await tester.tap(find.byKey(const ValueKey('private_pin_save')));
    await tester.pumpAndSettle();
    expect(preferences.getInt('private_pin_failed_attempts'), 1);
    expect(preferences.getString('private_article_pin'), '4826');

    await tester.enterText(
      find.byKey(const ValueKey('private_pin_current_input')),
      '4826',
    );
    await tester.enterText(
      find.byKey(const ValueKey('private_pin_new_input')),
      '1937',
    );
    await tester.enterText(
      find.byKey(const ValueKey('private_pin_confirm_input')),
      '1937',
    );
    tester.testTextInput.hide();
    await tester.tap(find.byKey(const ValueKey('private_pin_save')));
    await tester.pumpAndSettle();
    expect(preferences.getString('private_article_pin'), '1937');
    expect(preferences.getInt('private_pin_failed_attempts'), 0);
  });

  testWidgets('reader privacy switch is immediate and Shelf shows its tag', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'private_article_pin': '4826'});
    final preferences = await SharedPreferences.getInstance();
    final store = _MemoryArticleStore()
      ..saveSync(_article('article_to_lock', false));
    await tester.pumpWidget(
      TranshelfApp(preferences: preferences, articleStore: store),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav.shelf')));
    await tester.pumpAndSettle();
    final card = find.byKey(const ValueKey('article_article_to_lock'));
    await tester.tap(
      find.descendant(of: card, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reader_settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reader_private_toggle')));
    await tester.pumpAndSettle();
    expect((await store.load()).single.isPrivate, isTrue);

    await tester.tap(find.byKey(const ValueKey('reader_back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('article_article_to_lock')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('shelf_private_toggle')));
    await tester.pumpAndSettle();
    await _enterPin(tester, '4826');
    expect(
      find.byKey(const ValueKey('article_article_to_lock')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('article_private_tag_article_to_lock')),
      findsOneWidget,
    );

    final privateCard = find.byKey(const ValueKey('article_article_to_lock'));
    await tester.tap(
      find.descendant(of: privateCard, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reader_settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reader_private_toggle')));
    await tester.pumpAndSettle();
    expect((await store.load()).single.isPrivate, isFalse);
    await tester.tap(find.byKey(const ValueKey('reader_back')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('article_article_to_lock')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('article_private_tag_article_to_lock')),
      findsNothing,
    );
  });

  testWidgets('reaching the attempt limit deletes private articles and PIN', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'private_article_pin': '4826'});
    final preferences = await SharedPreferences.getInstance();
    final store = _MemoryArticleStore()
      ..saveSync(_article('public_after_lockout', false))
      ..saveSync(_article('private_after_lockout', true));
    await tester.pumpWidget(
      TranshelfApp(preferences: preferences, articleStore: store),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav.shelf')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('shelf_private_toggle')));
    await tester.pumpAndSettle();

    for (
      var attempt = 0;
      attempt < PrivatePinStore.failedAttemptLimit;
      attempt++
    ) {
      await _enterPin(tester, '0000');
    }

    expect(preferences.getInt('private_pin_failed_attempts'), 10);
    expect(preferences.getString('private_article_pin'), isNull);
    expect((await store.load()).map((item) => item.id), [
      'public_after_lockout',
    ]);
    expect(
      find.byKey(const ValueKey('private_pin_lockout_dialog')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('private_pin_lockout_dismiss')));
    await tester.pumpAndSettle();
  });
}

Future<void> _enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.byKey(ValueKey('private_pin_key_$digit')));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Article _article(String id, bool isPrivate) => Article(
  id: id,
  title: id,
  createdAt: DateTime.utc(2026, 10, 16),
  sourceLanguage: 'en',
  targetLanguage: 'zh-TW',
  service: 'google',
  isPrivate: isPrivate,
  segments: const [ArticleSegment(source: 'Source.', translation: '譯文。')],
);

class _MemoryArticleStore extends ArticleStore {
  final Map<String, Article> _articles = {};

  void saveSync(Article article) => _articles[article.id] = article;

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
