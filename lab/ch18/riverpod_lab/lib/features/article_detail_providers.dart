// lib/features/article_detail_providers.dart
// family 参数化 + autoDispose：一份声明派生按 id 独立演化的多个详情实例，
// 监听者归零即销毁——生命周期不再由手写缓存管理，交给 Riverpod Provider 容器
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_lab/core/feed_providers.dart';
import 'package:riverpod_lab/models/article.dart';

/// 按修饰符链声明：autoDispose 管「没人看就销毁」，family 管「按 id 各开一份」
/// 每个 id 各自缓存、各自加载、互不干扰，id 哪天有 100 个也是同这一行声明
final articleDetailProvider =
    FutureProvider.autoDispose.family<Article, int>((Ref ref, int id) async {
  // onDispose 是销毁缝：监听者归零触发，日志行供清单 15-5 回执抓取
  ref.onDispose(() {
    // ignore: avoid_print
    print('PROBE-E: articleDetail(id=$id) 实例销毁（autoDispose 生效）');
  });
  return ref.watch(feedRepositoryProvider).fetchArticleDetail(id);
});

/// 生命周期探针入口（由探针 main 调用，stdout 日志供清单 15-5 回执抓取）：
/// 第一段 watch 两个 id 演示实例独立演化，第二段解除监听演示 autoDispose 销毁
Future<void> probeLifecycle() async {
  // ProviderContainer：脱离 Widget 树跑 Riverpod Provider 的探针载体，
  // 与 ch14 直跑探针同一思路——不启 UI，只验数据与生命周期
  final ProviderContainer container = ProviderContainer();

  // 段一：同一声明监听两个 id，得到两个互不干扰的独立实例
  // ignore: avoid_print
  print('PROBE-E: P01 同时监听 id=1 与 id=2，两个 family 实例开始各自加载');
  final ProviderSubscription<AsyncValue<Article>> sub1 = container.listen(
    articleDetailProvider(1),
    (AsyncValue<Article>? previous, AsyncValue<Article> next) {},
  );
  final ProviderSubscription<AsyncValue<Article>> sub2 = container.listen(
    articleDetailProvider(2),
    (AsyncValue<Article>? previous, AsyncValue<Article> next) {},
  );

  final Article first = await container.read(articleDetailProvider(1).future);
  final Article second = await container.read(articleDetailProvider(2).future);
  // ignore: avoid_print
  print('PROBE-E: P02 独立演化坐实: id=1 → 「${first.title}」 id=2 → 「${second.title}」');

  // 段二：解除 id=1 的监听——无人再看，autoDispose 立即接管销毁
  // ignore: avoid_print
  print('PROBE-E: P03 解除 id=1 的监听，autoDispose 开始接管生命周期');
  sub1.close();
  // 给容器一个调度间隙，让销毁缝的日志行先于 P04 落到 stdout
  await Future<void>.delayed(Duration.zero);
  // ignore: avoid_print
  print('PROBE-E: P04 id=1 实例已销毁，id=2 仍在监听不受影响');

  sub2.close();
  container.dispose();
}
