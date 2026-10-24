// test/receipt.dart
// 回执落盘助手（验证臂专用，不属正文清单）：
// 回执落盘一律真异步区 + 回读 diff 校验（E13：FakeAsync 区 writeAsString 静默丢写）。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// testWidgets 场景：FakeAsync 区外落盘并回读 diff
Future<void> writeReceipt(WidgetTester tester, String name, List<String> lines) async {
  final String content = '${lines.join('\n')}\n';
  await tester.runAsync(() async {
    final File file = File('test/receipts/$name');
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  });
  final String? readback =
      await tester.runAsync(() async => File('test/receipts/$name').readAsString());
  expect(readback, content, reason: '$name 回执回读 diff 不一致（E13 防线）');
}

/// 普通 test() 场景：本身就在真异步区，直接落盘并回读 diff
Future<void> writeReceiptPlain(String name, List<String> lines) async {
  final String content = '${lines.join('\n')}\n';
  final File file = File('test/receipts/$name');
  await file.parent.create(recursive: true);
  await file.writeAsString(content);
  final String readback = await file.readAsString();
  expect(readback, content, reason: '$name 回执回读 diff 不一致（E13 防线）');
}
