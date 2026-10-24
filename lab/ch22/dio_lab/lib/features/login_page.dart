// lib/features/login_page.dart
// 登录页：第 22 章闭环的入口页。提交账号 → ApiClient.login 走生成客户端 →
// token 存进令牌缝 → 压入文章列表页；401 会话守卫清栈后也落回这里
import 'package:flutter/material.dart';

import 'package:dio_lab/core/api_client.dart';
import 'package:dio_lab/core/api_error.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _username = TextEditingController(text: 'teacher');
  final TextEditingController _password = TextEditingController(text: 'passw0rd');
  bool _submitting = false;
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ApiClient.instance.login(_username.text, _password.text);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/articles', (Route<dynamic> route) => false);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _errorMessage = mapDioError(error).message;
      });
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              key: const ValueKey<String>('username'),
              controller: _username,
              decoration: const InputDecoration(labelText: '用户名'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey<String>('password'),
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密码'),
            ),
            const SizedBox(height: 24),
            if (_submitting)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                key: const ValueKey<String>('login-submit'),
                onPressed: _submit,
                child: const Text('登录'),
              ),
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(_errorMessage!),
            ],
          ],
        ),
      ),
    );
  }
}
