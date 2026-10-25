// lib/main_gorouter.dart
// 实战 B：go_router 重写同一个应用（声明式路由表 + ShellRoute + redirect 守卫）
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  // Web deep link 入口：flutter run -d chrome 启动后，浏览器地址栏直输
  // http://localhost:<端口>/detail/2?title=xxx 可不经列表页直接落详情页
  runApp(const GoRouterApp());
}

/// 伪登录态：内存布尔 + ValueNotifier，只用 Flutter 自带能力
final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

/// 路由表：整份声明式配置，redirect 在每次导航前统一裁决
final GoRouter router = GoRouter(
  initialLocation: '/login',
  // 挂登录态做 refreshListenable：它一翻转，redirect 重新评估，登录后自动进壳
  refreshListenable: isLoggedIn,
  redirect: (BuildContext context, GoRouterState state) {
    final bool onLogin = state.matchedLocation == '/login';
    // 未登录访问任何壳内页面：打回 /login。
    // 教学版不做「登录后回原页」：重定向瞬间原 location 已换掉，
    // 真要记忆得从 state.uri 先存一份，正文要点留作扩展口
    if (!isLoggedIn.value && !onLogin) {
      return '/login';
    }
    // 已登录还停在登录页：直接送进列表页
    if (isLoggedIn.value && onLogin) {
      return '/list';
    }
    return null; // null 表示放行，不走重定向
  },
  routes: <RouteBase>[
    // login 在壳外：登录页不需要壳层的统一 AppBar
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginPage(),
    ),
    // ShellRoute 包住壳内页面：list / detail 共用同一个壳层布局
    ShellRoute(
      builder: (
        BuildContext context,
        GoRouterState state,
        Widget child,
      ) {
        return AppShell(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/list',
          builder: (BuildContext context, GoRouterState state) =>
              const ListPage(),
        ),
        // path 参数 /detail/:id，附加信息走查询参数 /detail/2?title=xxx
        GoRoute(
          path: '/detail/:id',
          builder: (BuildContext context, GoRouterState state) {
            final int id = int.parse(state.pathParameters['id']!);
            final String title =
                state.uri.queryParameters['title'] ?? '未知条目';
            return DetailPage(id: id, title: title);
          },
        ),
      ],
    ),
  ],
);

class GoRouterApp extends StatelessWidget {
  const GoRouterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // .router 构造：整棵路由树交给 routerConfig 接管，Web 地址栏与路由表直通
    return MaterialApp.router(
      title: 'router_lab 实战 B',
      routerConfig: router,
    );
  }
}