// 验证环境测试驱动（不入书）：清单 9-7 mounted 修复版竞态防线
import 'package:async_lab/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('清单9-7：3 秒内退出页面，迟到回调被 mounted 防线劝返',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AsyncLabApp());
    await tester.tap(find.text('打开慢汇报页（进去后 3 秒内按返回键）'));
    await tester.pumpAndSettle();
    expect(find.text('慢汇报页'), findsOneWidget);
    // 进入后立刻（3 秒内）退出页面
    final NavigatorState nav = tester.state(find.byType(Navigator));
    nav.pop();
    // 先让退出转场走完，State 真正 dispose（对齐真机时序）
    await tester.pumpAndSettle();
    // 等满 3 秒：迟到的回调此刻醒来
    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
    expect(find.text('迟到的弹窗'), findsNothing);
  });

  testWidgets('清单9-7：不退出页面时迟到回调正常执行（弹窗弹出）',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AsyncLabApp());
    await tester.tap(find.text('打开慢汇报页（进去后 3 秒内按返回键）'));
    await tester.pumpAndSettle();
    // 留在页面等满 3 秒
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('慢汇报已到达'), findsOneWidget);
    expect(find.text('迟到的弹窗'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
