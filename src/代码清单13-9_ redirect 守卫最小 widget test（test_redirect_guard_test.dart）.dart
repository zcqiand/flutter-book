// test/redirect_guard_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_lab/main_gorouter.dart';

void main() {
  testWidgets('未登录访问 /list 应被 redirect 打回 /login',
      (WidgetTester tester) async {
    // 全局 router 与登录态被同一套件共享，用例开头先归零，避免前序用例污染
    isLoggedIn.value = false;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // 模拟 Web 地址栏直输 /list：与 deep link 落守卫保护路径等价
    router.go('/list');
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(ListPage), findsNothing);
    expect(find.byType(DetailPage), findsNothing);
  });

  testWidgets('已登录访问 /list 放行', (WidgetTester tester) async {
    isLoggedIn.value = true;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // 登录态下 initialLocation /login 被 redirect 送进 /list，无需手动跳
    expect(find.byType(ListPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);

    // 收尾归零：全局登录态是进程级单例，还给后续用例一个干净起点
    isLoggedIn.value = false;
  });
}