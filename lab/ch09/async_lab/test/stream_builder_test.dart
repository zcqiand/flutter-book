// 验证环境测试驱动（不入书）：清单 9-3 StreamBuilder 三态 + 订阅清理
import 'package:async_lab/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('清单9-3 三态：启动为等待态，1.5 秒后第一批订单',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AsyncLabApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('订单 1001 · 已发货'), findsOneWidget);
    // 手动订阅的计时流也在走
    expect(find.text('已等待 2 秒'), findsOneWidget);
    // 测试驱动收尾（不入书）：把流推完三轮并关闭，
    // 否则 fake async 里挂着的下一笔 delayed 会触发 pending-timer 不变式
    // （与 future_builder_test 收尾同款处理）
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('清单9-3 三态：流三轮推齐后自然关闭（三笔订单全在）',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AsyncLabApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('订单 1002 · 待支付'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('订单 1003 · 已完成'), findsOneWidget);
    expect(find.text('已等待 6 秒'), findsOneWidget);
  });

  testWidgets('清单9-3 订阅清理：页面销毁后计时流不再触发 setState',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AsyncLabApp());
    await tester.pump(const Duration(seconds: 2));
    // 用空树替换页面，触发 dispose → 订阅 cancel
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });
}
