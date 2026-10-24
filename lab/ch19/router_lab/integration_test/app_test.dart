// integration_test/app_test.dart
// 集成测试：跑在真机或模拟器上的真实应用进程里；
// 与 Widget 测试共用 WidgetTester 写法，但执行载体完全不同。
//
// 【验证臂适配版】正文清单 19-2 原文在实仓不可编译/不可跑通，适配点四处
//（逐字版编译失败回执见 test/receipts/receipt-19-verbatim-capture.log）：
//  A1 import 入口 main.dart -> main_navigator.dart（实仓无 lib/main.dart，
//     实战 A 三级页应用实物入口为 main_navigator.dart）；
//  A2 登录页实物只有 1 个 TextField（账号），无密码框，删去第二个 enterText；
//  A3 '登录' 文本在 AppBar 标题与按钮上重复出现，find.text('登录') 歧义
//     （two widgets 抛 StateError），改 find.widgetWithText(FilledButton,'登录')；
//  A4 清单内 firstTitle='dio 拦截器：…' 与实仓数据面完全不符（疑串 dio 章），
//     按实物第一条数据改 'Navigator 路由基础'，textContaining 断言同步改。
// 除以上四处外与正文清单 19-2 逐字同构。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// A1：入口换实战 A 实物文件
import 'package:router_lab/main_navigator.dart' as app;

void main() {
  // 把测试框架接进真实应用进程：集成测试与 Widget 测试在代码面的第一个分岔
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('主流程：登录、列表、详情一条线走完', (tester) async {
    // 真实应用原样启动：此后的 settle 等的是真帧，不是假时钟
    app.main();
    await tester.pumpAndSettle();

    // 第一步：登录。A2：实物只有账号一个输入框
    await tester.enterText(find.byType(TextField).at(0), 'demo');
    // A3：消歧定位「登录」按钮
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    // 真实导航动画与登录守卫跳转都真金白银地走完，才轮到断言
    await tester.pumpAndSettle();

    // 断言一：列表页在场，文章标题可见（A4：断言锚实物数据）
    const String firstTitle = 'Navigator 路由基础';
    expect(find.byType(ListView), findsOneWidget);
    expect(find.textContaining('路由基础'), findsOneWidget);

    // 第二步：列表。点第一条文章项进详情；点之前把标题记住
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    // 断言二：详情页在场，标题与所点项一致
    expect(find.text(firstTitle), findsOneWidget);

    // 集成测试押主流程：用例按用户旅程组织，一条线跑到底，不做分支拆分
  });
}
