// 验证环境探针（不入书）：清单 11-6 CurveProgressBar 行为回执实抓。
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anim_lab/main.dart';

final List<String> _lines = <String>[];

void _rec(String msg) {
  final String line = '[11-6] $msg';
  _lines.add(line);
  // ignore: avoid_print
  print(line);
}

double _fillRatio(WidgetTester tester) {
  final double track =
      tester.getSize(find.byType(Container).first).width; // 轨道
  final double fill = tester
      .widget<Container>(
        find.descendant(
          of: find.byType(Container).first,
          matching: find.byType(Container),
        ),
      )
      .constraints
      ?.maxWidth ??
      0;
  return track > 0 ? fill / track : 0;
}

void main() {
  setUp(_lines.clear);
  tearDown(() async {
    final File f = File('test/receipts/receipt_11_6.txt');
    await f.parent.create(recursive: true);
    await f.writeAsString('${_lines.join('\n')}\n', flush: true);
  });

  testWidgets('清单11-6 CurveProgressBar：外部只给目标值，组件自己走过去',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AnimLabApp());
    await tester.pumpAndSettle();
    _rec('初始：目标进度=20%（文本「${tester.widget<Text>(find.byType(Text).first).data}」），首帧直接落在初始进度（构造 value 参数，无从 0 爬升）');
    _rec('初始：填充比实测=${_fillRatio(tester).toStringAsFixed(3)}');

    // +20% 一次：抓过渡中间帧（easeOutCubic 加速段-减速段）
    await tester.tap(find.text('+20%'));
    await tester.pump(); // 启动帧
    for (int i = 1; i <= 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      _rec('+20% 后 ${i * 100}ms：填充比=${_fillRatio(tester).toStringAsFixed(3)}（didUpdateWidget 续放，600ms 档进行中）');
    }
    await tester.pumpAndSettle();
    _rec('+20% settle：填充比=${_fillRatio(tester).toStringAsFixed(3)}，文本=「${tester.widget<Text>(find.byType(Text).first).data}」');
    expect(find.text('进度 40%'), findsOneWidget);
    expect(_fillRatio(tester), moreOrLessEquals(0.4, epsilon: 0.01));

    // 连点到顶：40 → 100
    await tester.tap(find.text('+20%'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+20%'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+20%'));
    await tester.pumpAndSettle();
    _rec('连点三次到顶：填充比=${_fillRatio(tester).toStringAsFixed(3)}（clamp(0,1) 封顶），文本=「${tester.widget<Text>(find.byType(Text).first).data}」');
    expect(find.text('进度 100%'), findsOneWidget);
    expect(_fillRatio(tester), moreOrLessEquals(1.0, epsilon: 0.01));

    // 归零：外部改一次 value，续放一次反向动画
    await tester.tap(find.text('归零'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    _rec('归零 150ms：填充比=${_fillRatio(tester).toStringAsFixed(3)}（反向进行中，非瞬跳）');
    await tester.pumpAndSettle();
    _rec('归零 settle：填充比=${_fillRatio(tester).toStringAsFixed(3)}，文本=「${tester.widget<Text>(find.byType(Text).first).data}」');
    expect(find.text('进度 0%'), findsOneWidget);
    expect(_fillRatio(tester), lessThan(0.02));
  });
}
