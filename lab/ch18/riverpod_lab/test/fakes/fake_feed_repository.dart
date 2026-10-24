// test/fakes/fake_feed_repository.dart
// mocktail 版数据层替身与 override 接线：替身只顶替数据层这一层，
// FeedNotifier 与三态页原封在场，状态转移逻辑仍在被测对象里真实运行
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:riverpod_lab/core/feed_providers.dart';
import 'package:riverpod_lab/models/article.dart';

/// extends Mock implements MockFeedRepository：mocktail 的 Mock 靠 noSuchMethod
/// 接住一切调用，implements 保证类型与真实仓库一致，override 才接得住
class FakeFeedRepository extends Mock implements MockFeedRepository {
  /// 快捷版：收 scenario 即按真实 mock 的三态开关一次预置全部行为
  FakeFeedRepository({MockScenario scenario = MockScenario.success})
      : _scenario = scenario { // ignore: prefer_initializing_formals — 验证臂豁免：改 initializing formal 须连带改调用点名
    restub(_scenario);
  }

  /// 脚本版：收闭包，返回行为完全交给测试自己编排
  FakeFeedRepository.scripted(Future<List<Article>> Function() script)
      : _scenario = MockScenario.success {
    when(() => fetchArticles()).thenAnswer((_) => script());
  }

  final MockScenario _scenario;

  // 与真实 MockFeedRepository 的种子数据逐字段一致
  // （DateTime 无常量构造，这里只能 final 不能 const）
  static final List<Article> seedArticles = <Article>[
    Article(
      id: 1,
      title: 'dio 拦截器：把横切关注点收进一条链',
      author: const Author(
        id: 7,
        name: '林晚风',
        avatarUrl: 'https://cdn.example.com/avatar/7.png',
      ),
      publishedAt: DateTime.utc(2026, 1, 5, 8, 30),
    ),
    Article(
      id: 2,
      title: 'json_serializable：让字段错误停在编译期',
      author: const Author(
        id: 9,
        name: '陈叙白',
        avatarUrl: 'https://cdn.example.com/avatar/9.png',
      ),
      publishedAt: DateTime.utc(2026, 1, 6, 9, 0),
    ),
  ];

  /// 测试中途切场景用：与真实 MockFeedRepository.scenario 静态开关同构
  void restub(MockScenario scenario) {
    switch (scenario) {
      case MockScenario.success:
        // thenAnswer 给异步返回值：非空列表，页面应落 data 态
        when(() => fetchArticles()).thenAnswer((_) async => seedArticles);
      case MockScenario.empty:
        // 空列表走同一注册口，页面应落 empty 态
        when(() => fetchArticles()).thenAnswer((_) async => const <Article>[]);
      case MockScenario.serverError:
        // thenThrow 让调用即抛：异常正好落进 load 的 catch，页面应落 error 态
        when(() => fetchArticles())
            .thenThrow(Exception('mock server error: HTTP 500'));
    }
  }
}

/// override 接线示范（有效配置就这两行）：替身只从数据层入口装进 Provider 图，
/// feedNotifierProvider 与页面不挂任何替身，这正是替身的活动边界
ProviderContainer wireFake(FakeFeedRepository fake) {
  return ProviderContainer(
    overrides: [
      feedRepositoryProvider.overrideWithValue(fake),
    ],
  );
}
