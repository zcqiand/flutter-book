// lib/legacy/manual_parse.dart
// Map 手工解析翻车现场复现：编译器全程零报错，运行到强转那一行才炸
//
// 背景：后端把 title 字段改名成了 article_title，本文件仍按旧字段名解析。
// 触发前把 ApiClient.scenario 切到 renamed 场景，mock 返回结构见清单 14-2 的 _renamedJson。

import 'package:dio_lab/core/api_client.dart';

/// 按旧字段名解析标题列表：每一步都「看起来没问题」
Future<List<String>> parseTitles() async {
  final dynamic body = await ApiClient.instance.fetchArticles();

  // 脆弱点一：字段名全是裸字符串。'data' 拼成 'Data'、'list' 拼成 'lisp'，
  // 编译器不认识这些键名，拼错了照样编译通过
  final Map<dynamic, dynamic> root = body as Map<dynamic, dynamic>;
  final List<dynamic> list = root['data'] as List<dynamic>;

  final List<String> titles = <String>[];
  for (final Map<dynamic, dynamic> item in list) {
    // 脆弱点二：as 硬转。后端已把 title 改成 article_title，
    // item['title'] 取出来是 null，null as String 在运行时直接抛 TypeError
    titles.add(item['title'] as String);
  }
  return titles;
  // 脆弱点三：没有编译期防线。模型层那种「字段对不上立刻标红」的保障，
  // 手工解析一项都没有，错误只能等真机跑起来才浮出水面。
}

/*
 * 预期运行时崩溃栈形态（逐字实抓回执见清单 14-7）：
 *
 * Unhandled exception:
 * type 'Null' is not a subtype of type 'String' in type cast
 * #0      parseTitles (package:dio_lab/legacy/manual_parse.dart:22:30)
 * ...
 *
 * 注意两点：报错信息里的 Null 和 String 都对不上任何一处业务代码的显式写法，
 * 栈顶指向的是自动生成的强转位置，与「哪个字段改了名」隔着好几层；
 * 编译器全程零报错，flutter analyze 也给不出任何提示。
 */