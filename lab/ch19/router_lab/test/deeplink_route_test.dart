// test/deeplink_route_test.dart
// deep link 路由解析测试：path 参数 + 查询参数解码 + 守卫对深链的拦截
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_lab/main_gorouter.dart';

void main() {
  testWidgets('已登录冷启深链 /detail/2?title=编码串 直接落详情页并解码中文',
      (WidgetTester tester) async {
    isLoggedIn.value = false;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // 登录后模拟地址栏直输带 path 参数与查询参数的深链
    isLoggedIn.value = true;
    await tester.pumpAndSettle();
    router.go('/detail/2?title=${Uri.encodeComponent('ShellRoute 壳层嵌套')}');
    await tester.pumpAndSettle();

    // 命中详情页：path 参数 id=2 拆成强类型字段，查询参数 title 解码还原中文
    expect(find.byType(DetailPage), findsOneWidget);
    expect(find.text('条目 id：2'), findsOneWidget);
    expect(find.text('标题：ShellRoute 壳层嵌套'), findsOneWidget);
    // 壳层常驻：深链落页也在 ShellRoute 壳内渲染
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('已登录'), findsOneWidget);

    isLoggedIn.value = false;
  });

  testWidgets('未登录直输深链 /detail/2 被 redirect 打回 /login',
      (WidgetTester tester) async {
    isLoggedIn.value = false;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/detail/2?title=x');
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(DetailPage), findsNothing);
  });
}
