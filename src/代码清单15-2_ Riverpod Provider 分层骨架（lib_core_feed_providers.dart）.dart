// lib/core/feed_providers.dart
// Riverpod Provider 分层骨架：数据层、业务层、展示层各占一个入口，
// 页面只允许 watch 展示层或业务层，永远不直接 new 数据源
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_lab/core/feed_notifier.dart';
import 'package:riverpod_lab/models/article.dart';

/// mock 场景开关：与 ch14 清单 14-2 同名，取其前三态即可切场景；renamed 属 ch14 对照专用，本工程用不到
/// success=成功非空；empty=空列表；serverError=服务端 500
enum MockScenario { success, empty, serverError }

/// 数据层：本地 mock 数据源，riverpod_lab 自持不依赖 dio_lab；
/// 文章数据与 ch14 清单 14-2 成功脚本同款，直构模型对象不走 json 解析
class MockFeedRepository {
  const MockFeedRepository();

  /// 场景开关：探针或页面改这里即可逐一切换三态，默认成功非空
  static MockScenario scenario = MockScenario.success;

  // 种子数据与 ch14 清单 14-2 的成功脚本逐字段一致，DateTime 用 UTC 构造保证可复现
  List<Article> get _seed => <Article>[
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

  /// 拉取文章列表：三态全靠这里路由，页面层感知不到 mock 的存在
  Future<List<Article>> fetchArticles() async {
    // 延迟 300ms 让 loading 态肉眼可见，与真实网络链路的节奏对齐
    await Future<void>.delayed(const Duration(milliseconds: 300));
    switch (MockFeedRepository.scenario) {
      case MockScenario.success:
        return _seed;
      case MockScenario.empty:
        return const <Article>[];
      case MockScenario.serverError:
        // 500 必须以异常形态出场：与 ch14 清单 14-2 的 reject 同理，
        // 错误态只能从异常分支走，返回值站不住
        throw Exception('mock server error: HTTP 500');
    }
  }

  /// 按 id 取详情：family 参数化（清单 15-4）的取数后端
  Future<Article> fetchArticleDetail(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    for (final Article article in _seed) {
      if (article.id == id) {
        return article;
      }
    }
    throw StateError('article $id not found');
  }
}

/// 数据层 Riverpod Provider：唯一的数据源取用入口，
/// 业务层与探针一律 ref.read 这里，数据源哪天换实现，调用点零改动
final Provider<MockFeedRepository> feedRepositoryProvider =
    Provider<MockFeedRepository>((Ref ref) => const MockFeedRepository());

/// 业务层 Riverpod Provider：只声明接线，FeedNotifier 的实现见清单 15-3
/// （lib/core/feed_notifier.dart），状态收敛逻辑不在本文件
final NotifierProvider<FeedNotifier, FeedState> feedNotifierProvider =
    NotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);

/// 展示层派生态：从业务状态派生「页面上实际看到什么」的只读值
final Provider<List<Article>> visibleArticlesProvider =
    Provider<List<Article>>((Ref ref) {
  // watch 业务层状态：状态一变，所有 watch 本派生 Riverpod Provider 的组件自动重建
  final FeedState state = ref.watch(feedNotifierProvider);
  // 教学版直接转发列表；要加关键字过滤，改成 state.articles.where(...) 即可，
  // 页面层与业务层零改动——派生层的价值就是把「看到什么」隔离在这一处
  return state.articles;
});