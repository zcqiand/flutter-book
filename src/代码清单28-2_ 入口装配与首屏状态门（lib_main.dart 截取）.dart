import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_controller.dart';
import 'core/auth/auth_state.dart';
import 'core/auth/login_page.dart';
import 'core/auth/sso_handoff.dart';
import 'core/config/app_config.dart';
import 'features/appadmin/client_list_page.dart';
import 'features/me/me_page.dart';
import 'features/tenants/tenants_list_page.dart';

void main() {
  AppConfig.validate(); // fail-fast：配置缺失不进 UI（suite 硬规则 §1）
  runApp(const ProviderScope(child: SaasFlutterApp()));
}

/// SSO 回跳参数（REQ-2026-012 M04.F03.I01）：启动时从地址栏解析一次；
/// 无参/非法 → null，走正常 console 流程。
final SsoParams? kSsoParams = SsoParams.fromUri(Uri.base);

class SaasFlutterApp extends ConsumerWidget {
  const SaasFlutterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return MaterialApp(
      title: 'SaaS 身份平台',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: switch (authState) {
        AuthRestoring() => const _Splash(),
        AuthAnonymous() ||
        AuthFailed() ||
        AuthSubmitting() => const LoginPage(),
        Authed() =>
          kSsoParams != null ? SsoHandoff(sso: kSsoParams!) : const _Shell(),
      },
    );
  }
}

// ……（节略：_Splash 加载页，与案例一同款）

/// Phase 1 占位壳：Phase 2 业务页落地前的已登录视图（含登出出口）。
class _Shell extends ConsumerWidget {
  const _Shell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SaaS 身份平台 Flutter 端'),
        actions: [
          // 「我」入口（REQ-2026-008 M01.F01.I01）：whoami + 成员关系 +
          // 切换当前租户。
          IconButton(
            tooltip: '我',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const MePage()),
            ),
          ),
          // 「应用」入口（REQ-2026-010 M04.F01.I01）：平台 admin 应用管理。
          IconButton(
            tooltip: '应用',
            icon: const Icon(Icons.apps),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const ClientListPage()),
            ),
          ),
          IconButton(
            tooltip: '登出',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: const TenantsListPage(),
    );
  }
}