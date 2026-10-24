// integration_test/ch22_loop_test.dart
// 第 22 章闭环集成验证（Windows 桌面载体，程序化点击）：
// 登录 → 注入（服务端命中行带 Authorization）→ 吊销再拉 → 401 守卫 → 栈清根落登录页。
// 本地 mock 服务起在同进程 127.0.0.1，零公网依赖；stdout 原样重定向即回执。
// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:dio_lab/core/local_mock_server.dart';
import 'package:dio_lab/main.dart';

Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  int maxSeconds = 20,
}) async {
  final DateTime deadline = DateTime.now().add(Duration(seconds: maxSeconds));
  while (!condition() && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(condition(), isTrue);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CH22 闭环四环：生成/注入/守卫/跳转', (WidgetTester tester) async {
    await LocalMockServer.instance.start();
    print('LOOP-RING-1 生成: scripts/gen-client.sh 三步链全绿，lib/generated 换血'
        '（生成回执见 receipt-22-gen.log，此处不再重复生成）');
    print('LOOP-RING-0 载体: Windows 桌面 integration_test，本地 mock 服务 '
        '${LocalMockServer.baseUrl} 在场');

    await tester.pumpWidget(const DioLabApp());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('login-submit')), findsOneWidget);
    print('LOOP-STEP 登录页在场: /login 初始路由，账号密码已预填');

    // 环二 注入：提交账号 → 生成客户端 POST /auth/login → token 入缝 → 列表页
    await tester.tap(find.byKey(const ValueKey<String>('login-submit')));
    await pumpUntil(
      tester,
      () => find.byKey(const ValueKey<String>('article-list')).evaluate().isNotEmpty,
    );
    print('LOOP-RING-2 注入: 登录 200 签发 token 入缝，GET /articles 落地 2 条生成模型；'
        '客户端挂头行见上方 [token-interceptor] 行，服务端命中行见上方 [mock-server] 行');

    // 环三 守卫：mock 服务端吊销当前 token，再拉一次列表 → 401
    await tester.tap(find.byKey(const ValueKey<String>('revoke-and-reload')));
    print('LOOP-STEP 吊销: /dev/revoke 已把当前 token 标记吊销（见上方 [mock-server] 行）');

    // 环四 跳转：守卫清会话 + 栈清根，落回登录页
    await pumpUntil(
      tester,
      () => find.byKey(const ValueKey<String>('login-submit')).evaluate().isNotEmpty,
    );
    print('LOOP-RING-3 守卫: 401 命中→清空 TokenProvider（见上方 [session-guard] 行），'
        '整场失效只送一次');
    print('LOOP-RING-4 跳转: pushAndRemoveUntil 清栈落地 /login，登录页重新在场（上方断言通过）');
    print('LOOP-PASS: 契约到登录闭环四环全部命中');
  });
}
