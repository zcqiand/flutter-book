import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_controller.dart';
import 'core/auth/auth_state.dart';
import 'core/auth/login_page.dart';
import 'core/config/app_config.dart';
import 'features/receipts/receipts_list_page.dart';

void main() {
  AppConfig.validate(); // fail-fast：配置缺失不进 UI（suite 硬规则 §1）
  runApp(const ProviderScope(child: LabFlutterApp()));
}

class LabFlutterApp extends ConsumerWidget {
  const LabFlutterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return MaterialApp(
      title: '实验室管理系统',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: switch (authState) {
        AuthRestoring() => const _Splash(),
        AuthAnonymous() ||
        AuthFailed() ||
        AuthSubmitting() => const LoginPage(),
        Authed() => const ReceiptsListPage(),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}