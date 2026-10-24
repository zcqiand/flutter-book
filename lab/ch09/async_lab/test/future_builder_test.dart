// 验证环境测试驱动（不入书）：清单 9-4 FutureBuilder 三态切换
import 'package:async_lab/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('清单9-4 三态：启动为等待态（加载圈）', (WidgetTester tester) async {
    await tester.pumpWidget(const AsyncLabApp());
    expect(find.text('订单列表 · FutureBuilder 版'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // 消费掉 2 秒定时器，避免测试收尾时报 pending timer
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('清单9-4 三态：2 秒后进入数据态（三笔订单）', (WidgetTester tester) async {
    await tester.pumpWidget(const AsyncLabApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('订单 1001 · 已发货'), findsOneWidget);
    expect(find.text('订单 1002 · 待支付'), findsOneWidget);
    expect(find.text('订单 1003 · 已完成'), findsOneWidget);
  });

  testWidgets('清单9-4 触发 rebuild 不闪回加载圈（future 存 State 字段）',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AsyncLabApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));
    // 再次挂同一个 app 触发 build 重跑
    await tester.pumpWidget(const AsyncLabApp());
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('订单 1003 · 已完成'), findsOneWidget);
  });
}
