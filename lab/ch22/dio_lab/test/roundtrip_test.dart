// test/roundtrip_test.dart
// 序列化往返测试：fromJson 进、toJson 出、再 fromJson 回，全程应无损
import 'package:flutter_test/flutter_test.dart';

import 'package:dio_lab/models/article.dart';

void main() {
  // 与清单 14-2 的 _successJson 同构：嵌套 Author、蛇形命名键、ISO 时间串
  final Map<String, dynamic> articleJson = <String, dynamic>{
    'id': 1,
    'title': 'dio 拦截器：把横切关注点收进一条链',
    'author': <String, dynamic>{
      'id': 7,
      'name': '林晚风',
      'avatar_url': 'https://cdn.example.com/avatar/7.png',
    },
    'published_at': '2026-01-05T08:30:00.000Z',
  };

  final Map<String, dynamic> pageJson = <String, dynamic>{
    'data': <Map<String, dynamic>>[articleJson],
    'page': 1,
    'total': 1,
  };

  test('Article 嵌套 Author 往返无损', () {
    final Article first = Article.fromJson(articleJson);
    final Map<String, dynamic> backJson = first.toJson();
    final Article second = Article.fromJson(backJson);

    // 教学版逐字段断言：哪个字段断了，测试输出直接点名，不用人工比对
    expect(second.id, first.id);
    expect(second.title, first.title);
    expect(second.author.id, first.author.id);
    expect(second.author.name, first.author.name);
    expect(second.author.avatarUrl, first.author.avatarUrl);
    expect(second.publishedAt, first.publishedAt);

    // toJson 出来的 map 应与源头 JSON 相等：序列化侧也必须无损
    expect(backJson, articleJson);
  });

  test('ApiPage<Article> 泛型包裹往返无损', () {
    final ApiPage<Article> first =
        ApiPage<Article>.fromJson(pageJson, Article.fromJson);
    final Map<String, dynamic> backJson =
        first.toJson((Article article) => article.toJson());
    final ApiPage<Article> second =
        ApiPage<Article>.fromJson(backJson, Article.fromJson);

    expect(second.data.length, first.data.length);
    expect(second.data[0].id, first.data[0].id);
    expect(second.data[0].author.name, first.data[0].author.name);
    expect(second.page, first.page);
    expect(second.total, first.total);

    expect(backJson, pageJson);
  });

  // 字段类型写错时编译期即报错：若把 id 写成字符串 '1'，
  // Article 构造函数要求 int，编译器当场标红，错误轮不到运行时出场。
  // 对照清单 14-6 的 as 硬转：同样的错误手工解析要等真机跑起来才炸。
  // Article broken = Article(id: '1', ...); 这行放开了就编译失败。
}
