// 验证 harness（verify 卡任务 2/5）：行为判据走 widget test。
// 病灶判据：pump 清单 8-1 布局（main_runnable.dart，与清单唯一差异是去 const）
// 必触发 RenderFlex overflow 断言，且溢出量=160 像素；
// 修复判据：pump 清单 8-3 布局（main_fixed.dart）零溢出，
// 且第一枚盒子 200 宽、第二枚（Expanded）恰好吃掉剩余 40 宽。
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overflow_lab/main_fixed.dart' as fixed;
import 'package:overflow_lab/main_runnable.dart' as disease;

void main() {
  testWidgets('病灶版：240 紧约束装两枚 200 盒，必报 overflow by 160 pixels', (tester) async {
    final errors = <FlutterErrorDetails>[];
    FlutterError.onError = (details) => errors.add(details);
    await tester.pumpWidget(const disease.OverflowLabApp());
    await tester.pump();
    expect(errors, isNotEmpty,
        reason: '病灶版必须触发渲染库断言（overflow），否则病灶未复现');
    expect(
      errors.map((e) => e.toString()).join('\n'),
      contains('A RenderFlex overflowed by 160 pixels on the right'),
    );

    // DevTools 占位替代素材②：布局完成后 dump 文本树，摘 RenderFlex 当事节点
    try {
      debugDumpRenderTree();
    } catch (_) {}
  });

  testWidgets('修复版：Expanded 接管剩余宽度——第一枚 200、第二枚恰 40，零溢出', (tester) async {
    final errors = <FlutterErrorDetails>[];
    FlutterError.onError = (details) => errors.add(details);
    await tester.pumpWidget(const fixed.OverflowLabApp());
    await tester.pump();
    expect(errors, isEmpty, reason: '修复后不得再有任何渲染断言');

    final orange = tester.renderObject(
      find.byWidgetPredicate((w) => w is Container && w.color == Colors.orangeAccent),
    ) as RenderBox;
    final deepOrange = tester.renderObject(
      find.byWidgetPredicate((w) => w is Container && w.color == Colors.deepOrange),
    ) as RenderBox;
    expect(orange.size.width, 200.0, reason: '第一枚定宽 200 不变');
    expect(deepOrange.size.width, 40.0, reason: '第二枚吃掉剩余 240-200=40，占满剩余宽度');
    expect(orange.size.height, 160.0);
    expect(deepOrange.size.height, 160.0);
  });
}
