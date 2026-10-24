// test/probe_manualparse_receipt_test.dart
// 回执 B 探针（flutter test 轨）：manual_parse.dart 运行时崩溃栈实抓
// 场景：后端已把 title 改名 article_title（见清单 14-2 _successJson），
// 旧字段名解析在 as String 强转处炸出 type 'Null' is not a subtype of type 'String'。
// 业务代码零捕获 → runZonedGuarded 收未捕获异常原样打印（卡面允许的 Zone 轨）。
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dio_lab/core/mock_interceptor.dart';
import 'package:dio_lab/legacy/manual_parse.dart';

void main() {
  void probe(String msg) => debugPrint('PROBE-B: $msg');

  test('回执 B：Map 手工解析运行时崩溃栈实抓（编译期零报错对照）', () async {
    // 场景开关切到 renamed（后端已把 title 改名 article_title，清单 14-6 前提）
    LegacyApiClient.scenario = MockScenario.renamed;
    final Completer<void> crashed = Completer<void>();

    unawaited(runZonedGuarded(
      () => parseTitles(), // 业务代码不 try：崩溃就是「未捕获」，与真机形态同构
      (Object error, StackTrace stack) {
        probe('P01 未捕获异常原样捕获（runZonedGuarded，业务代码零 try/catch）');
        probe('P02 --- 运行时崩溃栈开始（stdout 原样） ---');
        // ignore: avoid_print
        print('Unhandled exception:');
        // ignore: avoid_print
        print(error);
        // ignore: avoid_print
        print(stack);
        probe('P03 --- 运行时崩溃栈结束 ---');
        expect(error, isA<TypeError>());
        expect(
          error.toString(),
          contains("type 'Null' is not a subtype of type 'String' in type cast"),
        );
        probe('P04 崩溃点坐实: $error');
        probe('P05 栈顶帧坐实: parseTitles（package:dio_lab/legacy/manual_parse.dart）'
            '——栈信息只说 null 硬转 String，不说后端改了哪个字段');
        crashed.complete();
      },
    ));

    await crashed.future;
    probe('P06 对照声明: 本文件编译通过、flutter analyze 零提示，崩溃只在运行时出场；'
        '编译轨对照抓取见 receipt-B-compilerail-capture.log');
  });
}
