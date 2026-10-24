// test/feed_notifier_test.dart
// 纯 Dart 单元测试：不起 widget 树，只验 FeedNotifier 的状态转移；
// 数据层用内联 stub 顶替，业务层被测原件原封在场
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod_lab/core/feed_notifier.dart';
import 'package:riverpod_lab/core/feed_providers.dart';
import 'package:riverpod_lab/models/article.dart';

/// 内联手写 stub：extends 真实 MockFeedRepository 只为过 Provider 的类型检查，
/// fetchArticles 被整个覆写成零延迟直返，测试不再为 300ms 的肉眼可见性买单
class _StubFeedRepository extends MockFeedRepository {
  _StubFeedRepository({
    List<Article> articles = const <Article>[],
    this.shouldThrow = false,
  }) : _articles = articles; // ignore: prefer_initializing_formals — 验证臂豁免：改 initializing formal 须连带改调用点名

  final List<Article> _articles;
  final bool shouldThrow;

  @override
  Future<List<Article>> fetchArticles() async {
    if (shouldThrow) {
      // 与真实 mock 同构：错误必须以异常形态出场，返回值站不住
      throw Exception('stub: HTTP 500');
    }
    return _articles;
  }
}

Article _article(int id, String title) {
  return Article(
    id: id,
    title: title,
    author: Author(
      id: 100 + id,
      name: '测试作者',
      avatarUrl: 'https://cdn.example.com/avatar/$id.png',
    ),
    publishedAt: DateTime.utc(2026, 1, 5, 8, 30),
  );
}

/// 把自动首拉排干后读终态：build 里的 unawaited(load()) 与 stub 的零延迟返回
/// 全程只经过微任务队列，不经过任何真实定时器，两次 zero-delay 的宏任务间隔
/// 足以让队列连同状态替换全部跑完，此后的 read 拿到的一定是终态，
/// 断言因此具备确定性（纯 Dart 测试没有 widget 树，pumpAndSettle 在这里不存在）
Future<FeedState> readSettledState(ProviderContainer container) async {
  // 首次 read 必须先于排干发生：kick-off read 触发 build 与自动首拉，
  // 否则两次 zero-delay 排干期间无任务可排，末尾 read 拿到的是 build 同步快照 loading
  container.read(feedNotifierProvider);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  return container.read(feedNotifierProvider);
}

void main() {
  test('成功路径：非空列表落 data 态，两条记录可按标题断言', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(
          _StubFeedRepository(articles: <Article>[
            _article(1, 'dio 拦截器：把横切关注点收进一条链'),
            _article(2, 'json_serializable：让字段错误停在编译期'),
          ]),
        ),
      ],
    );
    // build 首次被 read 会自动发起首拉，容器若不兜底 dispose，
    // 挂起的 Provider 图可能让测试进程因未决句柄而超时
    addTearDown(container.dispose);

    final FeedState state = await readSettledState(container);
    expect(state.status, FeedStatus.data);
    expect(state.articles.length, 2);
    expect(state.articles.first.title, contains('拦截器'));
  });

  test('空态路径：空列表落 empty 态', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(_StubFeedRepository()),
      ],
    );
    addTearDown(container.dispose);

    final FeedState state = await readSettledState(container);
    expect(state.status, FeedStatus.empty);
  });

  test('错误路径：数据层抛异常落 error 态，文案为固定归一话术', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(
          _StubFeedRepository(shouldThrow: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    final FeedState state = await readSettledState(container);
    expect(state.status, FeedStatus.error);
    expect(state.errorMessage, '加载失败，请稍后重试');
  });
}
