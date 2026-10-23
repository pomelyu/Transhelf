class ArticleSegment {
  const ArticleSegment({required this.source, required this.translation});

  final String source;
  final String translation;

  Map<String, Object?> toJson() => {
    'source': source,
    'translation': translation,
  };

  factory ArticleSegment.fromJson(Map<String, dynamic> json) => ArticleSegment(
    source: json['source'] as String,
    translation: json['translation'] as String,
  );
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.service,
    required this.segments,
    this.progress = 0,
    this.isPrivate = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final String sourceLanguage;
  final String targetLanguage;
  final String service;
  final List<ArticleSegment> segments;
  final double progress;
  final bool isPrivate;

  String get excerpt => segments.isEmpty ? '' : segments.first.translation;

  Article withProgress(double value) => Article(
    id: id,
    title: title,
    createdAt: createdAt,
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
    service: service,
    segments: segments,
    progress: value.clamp(0, 1),
    isPrivate: isPrivate,
  );

  Article withTitle(String value) => Article(
    id: id,
    title: value,
    createdAt: createdAt,
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
    service: service,
    segments: segments,
    progress: progress,
    isPrivate: isPrivate,
  );

  Article withPrivacy(bool value) => Article(
    id: id,
    title: title,
    createdAt: createdAt,
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
    service: service,
    segments: segments,
    progress: progress,
    isPrivate: value,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'sourceLanguage': sourceLanguage,
    'targetLanguage': targetLanguage,
    'service': service,
    'progress': progress,
    'isPrivate': isPrivate,
    'segments': segments.map((segment) => segment.toJson()).toList(),
  };

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    id: json['id'] as String,
    title: json['title'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    sourceLanguage: json['sourceLanguage'] as String,
    targetLanguage: json['targetLanguage'] as String,
    service: json['service'] as String,
    progress: (json['progress'] as num?)?.toDouble() ?? 0,
    isPrivate: json['isPrivate'] as bool? ?? false,
    segments: (json['segments'] as List<dynamic>)
        .map((entry) => ArticleSegment.fromJson(entry as Map<String, dynamic>))
        .toList(),
  );
}
