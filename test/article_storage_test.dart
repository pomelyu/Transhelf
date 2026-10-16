import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:transhelf/models/article.dart';
import 'package:transhelf/services/article_segmenter.dart';
import 'package:transhelf/services/article_store.dart';

void main() {
  test('joins short blank-line paragraphs and retains a short tail', () {
    const sentence = 'This sentence has enough letters.';
    final source = [
      sentence * 2,
      sentence * 3,
      '這段中文至少有十個字所以可以計算。',
    ].join('\n\n');
    final parts = ArticleSegmenter.split(source);
    expect(parts, hasLength(2));
    expect(parts.first, '${sentence * 2}\n\n${sentence * 3}');
    expect(parts.last, '這段中文至少有十個字所以可以計算。');
    expect(ArticleSegmenter.countSentences('Short. Long enough sentence!'), 1);
  });

  test('writes each article as JSON and updates reading progress', () async {
    final directory = await Directory.systemTemp.createTemp('transhelf-test-');
    addTearDown(() => directory.delete(recursive: true));
    final store = ArticleStore(directory: () async => directory);
    final article = Article(
      id: 'article_1',
      title: 'Title',
      createdAt: DateTime.utc(2026, 10, 14),
      sourceLanguage: 'en',
      targetLanguage: 'zh-TW',
      service: 'google',
      segments: const [ArticleSegment(source: 'Hello.', translation: '你好。')],
    );
    await store.save(article);
    final saved = File('${directory.path}/articles/article_1.json');
    expect(await saved.exists(), isTrue);
    expect((await saved.readAsString()).contains('"isPrivate":false'), isTrue);
    expect((await store.load()).single.segments.single.source, 'Hello.');
    await store.save(article.withProgress(0.5));
    expect((await store.load()).single.progress, 0.5);
    await store.delete(article.id);
    expect(await store.load(), isEmpty);
  });

  test('deletes private articles without affecting public articles', () async {
    final directory = await Directory.systemTemp.createTemp('transhelf-test-');
    addTearDown(() => directory.delete(recursive: true));
    final store = ArticleStore(directory: () async => directory);
    Article article(String id, bool isPrivate) => Article(
      id: id,
      title: id,
      createdAt: DateTime.utc(2026, 10, 16),
      sourceLanguage: 'en',
      targetLanguage: 'zh-TW',
      service: 'google',
      isPrivate: isPrivate,
      segments: const [ArticleSegment(source: 'Source.', translation: '譯文。')],
    );

    await store.save(article('public', false));
    await store.save(article('private_one', true));
    await store.save(article('private_two', true));
    await store.deletePrivateArticles();

    final remaining = await store.load();
    expect(remaining.map((item) => item.id), ['public']);
  });
}
