abstract final class ArticleSegmenter {
  static const minimumSentences = 5;
  static const minimumLettersPerSentence = 10;

  static final _sentence = RegExp(r'[^.;!?。；！？]+[.;!?。；！？]');
  static final _letter = RegExp(r'\p{L}', unicode: true);

  static List<String> split(String text) {
    final paragraphs = text
        .trim()
        .split(RegExp(r'\r?\n\s*\r?\n'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    final groups = <String>[];
    final pending = <String>[];
    var sentences = 0;
    for (final paragraph in paragraphs) {
      pending.add(paragraph);
      sentences += countSentences(paragraph);
      if (sentences >= minimumSentences) {
        groups.add(pending.join('\n\n'));
        pending.clear();
        sentences = 0;
      }
    }
    if (pending.isNotEmpty) groups.add(pending.join('\n\n'));
    return groups;
  }

  static int countSentences(String text) => _sentence
      .allMatches(text)
      .where(
        (match) =>
            _letter.allMatches(match.group(0)!).length >=
            minimumLettersPerSentence,
      )
      .length;
}
