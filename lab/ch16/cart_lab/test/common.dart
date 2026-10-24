// test/common.dart
// 四方案共用的七步脚本驱动器（同题共答）：
// 加购（重复加购数量+1）、逐项+1/-1（减到 0 移除）、结算行实时数、一键清空。
// 每步断言 PASS 后落回执 test/receipts/<scheme>.txt（真异步写）并回读 diff 校验。
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> runCartScript(WidgetTester tester, String scheme, Widget page) async {
  await tester.binding.setSurfaceSize(const Size(800, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final List<String> lines = <String>['RECEIPT_BEGIN|$scheme'];
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: page)));
  await tester.pumpAndSettle();

  Future<void> tapShelfAdd(String name) async {
    final Finder tile = find
        .ancestor(of: find.text(name), matching: find.byType(ListTile))
        .first;
    await tester.tap(find.descendant(
        of: tile, matching: find.byIcon(Icons.add_shopping_cart)));
    await tester.pumpAndSettle();
  }

  Future<void> tapRow(String name, IconData icon) async {
    final Finder row = find
        .ancestor(of: find.textContaining('$name '), matching: find.byType(Row))
        .first;
    await tester.tap(find.descendant(of: row, matching: find.byIcon(icon)));
    await tester.pumpAndSettle();
  }

  Future<void> tapClear() async {
    await tester.tap(find.widgetWithText(TextButton, '清空购物车'));
    await tester.pumpAndSettle();
  }

  String settlement() =>
      tester.widget<Text>(find.textContaining('共 ')).data!;

  final List<(String, Future<void> Function(), String)> steps =
      <(String, Future<void> Function(), String)>[
    ('step1-加购键盘', () => tapShelfAdd('键盘'), '共 1 种，合计 199.00 元'),
    ('step2-重复加购键盘(数量+1)', () => tapShelfAdd('键盘'), '共 1 种，合计 398.00 元'),
    ('step3-加购鼠标与显示器', () async {
      await tapShelfAdd('鼠标');
      await tapShelfAdd('显示器');
    }, '共 3 种，合计 1486.00 元'),
    ('step4-键盘-1', () => tapRow('键盘', Icons.remove_circle_outline),
        '共 3 种，合计 1287.00 元'),
    ('step5-键盘再-1(减到0移除)', () => tapRow('键盘', Icons.remove_circle_outline),
        '共 2 种，合计 1088.00 元'),
    ('step6-鼠标+1', () => tapRow('鼠标', Icons.add_circle_outline),
        '共 2 种，合计 1177.00 元'),
    ('step7-一键清空', () => tapClear(), '共 0 种，合计 0.00 元'),
  ];

  for (final (String label, Future<void> Function() act, String expected)
      in steps) {
    await act();
    final String actual = settlement();
    final bool ok = actual == expected;
    lines.add('STEP|$label|actual=$actual|expected=$expected|${ok ? 'PASS' : 'FAIL'}');
    debugPrint('CART_TEST|$scheme|$label|$actual');
    expect(ok, isTrue, reason: '$scheme $label: actual=$actual');
  }
  lines.add('RECEIPT_END|$scheme');

  // 回执落盘（真异步区：testWidgets 的 FakeAsync 会吞掉真 IO，必须 runAsync 逃逸）+ 回读 diff
  final String content = '${lines.join('\n')}\n';
  await tester.runAsync(() async {
    final File file = File('test/receipts/$scheme.txt');
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  });
  final String? readback = await tester
      .runAsync(() async => File('test/receipts/$scheme.txt').readAsString());
  expect(readback, content, reason: '$scheme 回执回读 diff 不一致');
}
