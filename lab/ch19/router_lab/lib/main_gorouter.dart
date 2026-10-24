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

/// 列表项模型：与实战 A 同构，双入口文件各自独立可跑
class Item {
  const Item({required this.id, required this.title});

  final int id;
  final String title;
}

/// 壳层：统一 AppBar + 登录态角标，子路由页面渲染在 body 的 child 里
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('router_lab 实战 B'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              // 只让角标这一小块监听登录态：壳层其余部分不随登录态重建
              child: ValueListenableBuilder<bool>(
                valueListenable: isLoggedIn,
                builder: (BuildContext context, bool value, Widget? _) =>
                    Text(value ? '已登录' : '未登录'),
              ),
            ),
          ),
        ],
      ),
      body: child,
    );
  }
}

/// 登录页：只翻转登录态，跳转交给 redirect
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            // refreshListenable 感知到翻转后自动重定向去 /list，这里不写跳转
            isLoggedIn.value = true;
          },
          child: const Text('登录'),
        ),
      ),
    );
  }
}

/// 列表页：push 到详情并等收藏结果回传
class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final List<Item> _items = const <Item>[
    Item(id: 1, title: 'go_router 声明式路由'),
    Item(id: 2, title: 'ShellRoute 壳层嵌套'),
    Item(id: 3, title: 'redirect 登录守卫'),
  ];

  final Set<int> _favoriteIds = <int>{};

  Future<void> _openDetail(Item item) async {
    // 标题经 URL 编码：中文与空格不编码，Web 下 deep link 会失真
    final String encoded = Uri.encodeComponent(item.title);
    // context.push 返回 Future，详情页 pop 带回的结果在这里拿到
    final bool? result =
        await context.push<bool>('/detail/${item.id}?title=$encoded');
    if (result != null) {
      setState(() {
        if (result) {
          _favoriteIds.add(item.id);
        } else {
          _favoriteIds.remove(item.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) {
        final Item item = _items[index];
        return ListTile(
          leading: _favoriteIds.contains(item.id)
              ? const Icon(Icons.favorite, color: Colors.red)
              : const Icon(Icons.favorite_border),
          title: Text(item.title),
          subtitle: Text('id: ${item.id}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openDetail(item),
        );
      },
    );
  }
}

/// 详情页：path 参数与查询参数在路由表里已拆成强类型字段
class DetailPage extends StatefulWidget {
  const DetailPage({
    super.key,
    required this.id,
    required this.title,
  });

  final int id;
  final String title;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    // Web 深链可直达本页、无人传初始收藏态，统一从「未收藏」起步；
    // 要带初始态可加查询参数 isFav=1，教学版不展开
    _isFavorite = false;
  }

  void _saveAndPop() {
    // go_router 版回传：context.pop 泛型标明结果类型，与 push<bool> 对齐
    context.pop<bool>(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 壳层 AppBar 是公用的，本页自带返回钮走壳内嵌套导航栈
            BackButton(onPressed: () => context.pop<bool>(null)),
            const SizedBox(height: 8),
            Text('条目 id：${widget.id}'),
            const SizedBox(height: 8),
            Text('标题：${widget.title}'),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
              child: Text(_isFavorite ? '已收藏（点此取消）' : '未收藏（点此收藏）'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveAndPop,
              child: const Text('保存并返回列表'),
            ),
          ],
        ),
      ),
    );
  }
}
