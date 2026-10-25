// integration_test/app_test.dart
// 集成测试：跑在真机或模拟器上的真实应用进程里；
// 与 Widget 测试共用 WidgetTester 写法，但执行载体完全不同
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:router_lab/main_navigator.dart' as app;

void main() {
  // 把测试框架接进真实应用进程：集成测试与 Widget 测试在代码面的第一个分岔
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('主流程：登录、列表、详情一条线走完', (tester) async {
    // 真实应用原样启动：此后的 settle 等的是真帧，不是假时钟
    app.main();
    await tester.pumpAndSettle();

    // 第一步：登录。账号喂进唯一的输入框；
    await tester.enterText(find.byType(TextField).at(0), 'demo');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    // 真实导航动画与页面跳转都真金白银地走完，才轮到断言
    await tester.pumpAndSettle();

    // 断言一：列表页在场，文章标题可见
    const String firstTitle = 'Navigator 路由基础';
    expect(find.byType(ListView), findsOneWidget);
    expect(find.textContaining('路由基础'), findsOneWidget);

    // 第二步：列表。点第一条文章项进详情；
    // 点之前把标题文本记住，详情页要与它对得上
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    // 断言二：详情页在场，标题与所点项一致
    expect(find.text(firstTitle), findsOneWidget);

    // 集成测试押主流程：用例按用户旅程组织，一条线跑到底，不做分支拆分
  });
}