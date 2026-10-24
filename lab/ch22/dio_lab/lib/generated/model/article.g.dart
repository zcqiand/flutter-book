// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Article extends Article {
  @override
  final int id;
  @override
  final String title;
  @override
  final String authorName;

  factory _$Article([void Function(ArticleBuilder)? updates]) =>
      (ArticleBuilder()..update(updates))._build();

  _$Article._({required this.id, required this.title, required this.authorName})
    : super._();
  @override
  Article rebuild(void Function(ArticleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ArticleBuilder toBuilder() => ArticleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Article &&
        id == other.id &&
        title == other.title &&
        authorName == other.authorName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, authorName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Article')
          ..add('id', id)
          ..add('title', title)
          ..add('authorName', authorName))
        .toString();
  }
}

class ArticleBuilder implements Builder<Article, ArticleBuilder> {
  _$Article? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _authorName;
  String? get authorName => _$this._authorName;
  set authorName(String? authorName) => _$this._authorName = authorName;

  ArticleBuilder() {
    Article._defaults(this);
  }

  ArticleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _authorName = $v.authorName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Article other) {
    _$v = other as _$Article;
  }

  @override
  void update(void Function(ArticleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Article build() => _build();

  _$Article _build() {
    final _$result =
        _$v ??
        _$Article._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Article', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'Article',
            'title',
          ),
          authorName: BuiltValueNullFieldError.checkNotNull(
            authorName,
            r'Article',
            'authorName',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
