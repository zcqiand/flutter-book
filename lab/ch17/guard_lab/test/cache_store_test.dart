// test/cache_store_test.dart
// 清单 17-8 cache 段测试：sqflite 经 sqflite_common_ffi 在测试机跑真 SQLite（真实建表/插查删），
// 回执落盘 test/receipts/17_9_cache.txt。
// 说明：sqflite 基础包在 Windows 桌面/测试 VM 无平台实现，须 ffi 工厂；正文 CacheStore
// 未提供删除 API，删除段经 store 暴露的 database 连接执行（差异已回报 verify.md）。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:guard_lab/storage/cache_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'receipt.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final Directory temp = await Directory.systemTemp.createTemp('guard_lab_cache_test');
    await databaseFactory.setDatabasesPath(temp.path);
  });

  test('缓存层：建表写查覆盖删除（清单17-9 cache 段）', () async {
    final CacheStore store = CacheStore.instance;
    final List<String> lines = <String>['RECEIPT_BEGIN|17_9_cache'];

    // step1 写入三行
    await store.putArticles(<Map<String, Object?>>[
      <String, Object?>{'id': 1, 'title': '文章一', 'summary': '摘要一', 'updated_at': 1000},
      <String, Object?>{'id': 2, 'title': '文章二', 'summary': '摘要二', 'updated_at': 2000},
      <String, Object?>{'id': 3, 'title': '文章三', 'summary': '摘要三', 'updated_at': 3000},
    ]);
    final List<Map<String, Object?>> rows1 = await store.loadArticles();
    lines.add('STEP|step1-写入三行|actual=${rows1.length} 行|expected=3 行|${rows1.length == 3 ? 'PASS' : 'FAIL'}');

    // step2 按 updated_at 倒序读出：首行为最新
    final String firstTitle = '${rows1.first['title']}';
    lines.add('STEP|step2-倒序首行|actual=$firstTitle|expected=文章三|${firstTitle == '文章三' ? 'PASS' : 'FAIL'}');

    // step3 upsert：重复写同 id 覆盖旧行，行数不涨、内容更新
    await store.putArticles(<Map<String, Object?>>[
      <String, Object?>{'id': 1, 'title': '文章一(更新)', 'summary': '摘要一', 'updated_at': 4000},
    ]);
    final List<Map<String, Object?>> rows3 = await store.loadArticles();
    final String updatedTitle = '${rows3.firstWhere((Map<String, Object?> r) => r['id'] == 1)['title']}';
    final bool ok3 = rows3.length == 3 && updatedTitle == '文章一(更新)';
    lines.add('STEP|step3-同id覆盖|actual=${rows3.length} 行, id1=$updatedTitle|expected=3 行, id1=文章一(更新)|${ok3 ? 'PASS' : 'FAIL'}');

    // step4 删除一行：经 store 暴露的 database 连接执行 delete
    final Database db = await store.database;
    final int deleted = await db.delete('article_cache', where: 'id = ?', whereArgs: <Object>[2]);
    final List<Map<String, Object?>> rows4 = await store.loadArticles();
    final bool ok4 = deleted == 1 && rows4.length == 2;
    lines.add('STEP|step4-删除id=2|actual=deleted=$deleted, 剩${rows4.length} 行|expected=deleted=1, 剩2 行|${ok4 ? 'PASS' : 'FAIL'}');

    // step5 清空：删后再读必须为空
    await db.delete('article_cache');
    final List<Map<String, Object?>> rows5 = await store.loadArticles();
    lines.add('STEP|step5-清空后读|actual=${rows5.length} 行|expected=0 行|${rows5.isEmpty ? 'PASS' : 'FAIL'}');

    lines.add('RECEIPT_END|17_9_cache');
    for (final String line in lines.where((String l) => l.startsWith('STEP|'))) {
      expect(line.endsWith('|PASS'), isTrue, reason: line);
    }
    await writeReceiptPlain('17_9_cache.txt', lines);
  });
}
