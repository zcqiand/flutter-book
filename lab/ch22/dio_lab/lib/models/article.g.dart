// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  avatarUrl: json['avatar_url'] as String,
);

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar_url': instance.avatarUrl,
};

Article _$ArticleFromJson(Map<String, dynamic> json) => Article(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  publishedAt: DateTime.parse(json['published_at'] as String),
);

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'author': instance.author.toJson(),
  'published_at': instance.publishedAt.toIso8601String(),
};

ApiPage<T> _$ApiPageFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiPage<T>(
  data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
  page: (json['page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$ApiPageToJson<T>(
  ApiPage<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'data': instance.data.map(toJsonT).toList(),
  'page': instance.page,
  'total': instance.total,
};
