import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/article.dart';

class ArticleStore {
  ArticleStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directory;

  Future<Directory> _articlesDirectory() async {
    final root = await _directory();
    final articles = Directory('${root.path}/articles');
    if (!await articles.exists()) await articles.create(recursive: true);
    return articles;
  }

  Future<List<Article>> load() async {
    final directory = await _articlesDirectory();
    final articles = <Article>[];
    await for (final entry in directory.list()) {
      if (entry is! File || !entry.path.endsWith('.json')) continue;
      try {
        final json =
            jsonDecode(await entry.readAsString()) as Map<String, dynamic>;
        articles.add(Article.fromJson(json));
      } on FormatException {
        // A damaged article must not hide the other saved articles.
      } on TypeError {
        // Ignore a file with an invalid schema.
      } on FileSystemException {
        // Ignore an unreadable file without hiding the other articles.
      }
    }
    return articles;
  }

  Future<void> save(Article article) async {
    final file = await _fileFor(article.id);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(article.toJson()), flush: true);
    await temporary.rename(file.path);
  }

  Future<void> delete(String id) async {
    final file = await _fileFor(id);
    if (await file.exists()) await file.delete();
  }

  Future<void> deletePrivateArticles() async {
    final articles = await load();
    for (final article in articles.where((article) => article.isPrivate)) {
      await delete(article.id);
    }
  }

  Future<File> _fileFor(String id) async {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id)) {
      throw ArgumentError.value(id, 'id', 'Invalid article id');
    }
    final directory = await _articlesDirectory();
    return File('${directory.path}/$id.json');
  }
}
