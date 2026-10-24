// lib/main.dart
// lab 自持入口：第 22 章形态——先起本地 mock 服务（127.0.0.1，零公网），
// 再挂全局页面栈钥匙与两条路由（/login、/articles），闭环四环在此跑通
import 'package:flutter/material.dart';

import 'package:dio_lab/core/local_mock_server.dart';
import 'package:dio_lab/core/session_guard.dart';
import 'package:dio_lab/features/article_list_page.dart';
import 'package:dio_lab/features/login_page.dart';

Future<void> main() async {
  await LocalMockServer.instance.start();
  runApp(const DioLabApp());
}

class DioLabApp extends StatelessWidget {
  const DioLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dio_lab',
      // 全局页面栈钥匙：401 会话守卫在 Widget 树之外靠它清栈落登录页
      navigatorKey: navigatorKey,
      initialRoute: '/login',
      routes: <String, WidgetBuilder>{
        '/login': (_) => const LoginPage(),
        '/articles': (_) => const ArticleListPage(),
      },
    );
  }
}
