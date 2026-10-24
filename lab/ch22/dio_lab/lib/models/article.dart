// lib/models/article.dart
// article.g.dart 由 build_runner 生成，是构建产物不手改；
// 生成命令：dart run build_runner build --delete-conflicting-outputs
import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';

@JsonSerializable()
class Author {
  const Author({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  final int id;
  final String name;

  // json 键是蛇形命名 avatar_url，Dart 侧保持小驼峰，映射关系写一处即可
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;

  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}

// explicitToJson 让嵌套的 author 在 toJson 时调用 Author.toJson 生成子 Map；
// 不开这个开关，嵌套对象会被原样塞进 map，序列化往返的对称性就断了
@JsonSerializable(explicitToJson: true)
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.author,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);

  final int id;
  final String title;
  final Author author;

  // DateTime 的互转 json_serializable 原生支持，按 ISO 8601 字符串编解码
  @JsonKey(name: 'published_at')
  final DateTime publishedAt;

  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}

/// 泛型分页包裹：data 的元素类型由调用方指定，本工程固定为 ApiPage<Article>
/// genericArgumentFactories 让生成代码带上 T 的转换函数参数
/// 类名取 ApiPage 而非 Page：Flutter 框架层已有同名 Page 类，避免混引歧义
@JsonSerializable(genericArgumentFactories: true)
class ApiPage<T> {
  const ApiPage({
    required this.data,
    required this.page,
    required this.total,
  });

  factory ApiPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) =>
      // 生成物要求的转换函数签名是 T Function(Object?)，
      // 这里在工厂体内包一层窄化适配，fromJsonT 的对外签名保持不变，
      // 调用点仍可直接传 Article.fromJson
      _$ApiPageFromJson(
        json,
        (Object? jsonT) => fromJsonT(jsonT as Map<String, dynamic>),
      );

  final List<T> data;
  final int page;
  final int total;

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      _$ApiPageToJson(this, toJsonT);
}
