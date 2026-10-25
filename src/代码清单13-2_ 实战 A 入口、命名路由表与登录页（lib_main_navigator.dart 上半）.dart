// lib/main_navigator.dart
// 实战 A：命名路由 + MaterialPageRoute 直 push 两种式子并存
import 'package:flutter/material.dart';

void main() {
  runApp(const NavigatorApp());
}

/// 列表项数据模型：id 参与收藏判定与详情展示，title 用于列表与详情标题
class Item {
  const Item({required this.id, required this.title});

  final int id;
  final String title;
}

class NavigatorApp extends StatelessWidget {
  const NavigatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'router_lab 实战 A',
      // 命名路由表：有「固定入口语义」的页面登记在表里，字符串名字即可跳转
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const LoginPage(),
        '/list': (BuildContext context) => const ListPage(),
      },
    );
  }
}

/// 登录页：教学用伪登录，只演示跳转，不接真实鉴权
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _accountController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  void _login() {
    // 用 pushReplacementNamed 而非 pushNamed：把栈底的 '/' 替换掉，
    // 否则用户在列表页按返回键会退回登录页，体验上等于「退出登录」
    Navigator.of(context).pushReplacementNamed('/list');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _accountController,
              decoration: const InputDecoration(labelText: '账号'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _login,
              child: const Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
}