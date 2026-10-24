// lib/models/article.dart
// 纯手写模型：与 ch14 清单 14-2 的 Article/Author 字段逐一同名同型，
// 但本工程 mock 直构不走 json 解析，json_annotation 与 .g.dart 生成物整排不需要
class Author {
  const Author({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  final int id;
  final String name;
  final String avatarUrl;
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.author,
    required this.publishedAt,
  });

  final int id;
  final String title;
  final Author author;
  final DateTime publishedAt;
}
