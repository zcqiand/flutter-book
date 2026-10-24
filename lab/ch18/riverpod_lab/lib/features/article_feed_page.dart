// lib/features/article_feed_page.dart
// 三态页 Riverpod 重构版：状态住进 FeedNotifier（清单 15-3），页面只 watch 与渲染
// 三态语义与清单 14-5 完全一致，变的是状态位置：从 State 字段搬进业务层快照
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_lab/core/feed_notifier.dart';
import 'package:riverpod_lab/core/feed_providers.dart';
import 'package:riverpod_lab/models/article.dart';

/// ConsumerWidget：build 多一个 ref 参数，watch 到哪层状态就因哪层重建
class ArticleFeedPage extends ConsumerWidget {
  const ArticleFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 首拉由 FeedNotifier.build 自身承载，页面零 initState 零手动触发：
    // Riverpod Provider 首次被 watch 时自动进入 loading 并发起拉取
    final FeedState state = ref.watch(feedNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('文章列表')),
      // 演示方法与 ch14 一致：改 MockFeedRepository.scenario 后触发 load 逐一切换三态
      // success 对应数据态，empty 对应空态，serverError 对应错误态
      body: switch (state.status) {
        FeedStatus.loading => const Center(child: CircularProgressIndicator()),
        FeedStatus.empty => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('暂无文章'),
                const SizedBox(height: 12),
                ElevatedButton(
                  // 重新加载=通知业务层重跑 load，加载流程本身不归页面管
                  onPressed: () =>
                      ref.read(feedNotifierProvider.notifier).load(),
                  child: const Text('重新加载'),
                ),
              ],
            ),
          ),
        FeedStatus.error => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(state.errorMessage),
                const SizedBox(height: 12),
                ElevatedButton(
                  // 重试走 retry，与重新加载同指一条路径（语义同清单 14-5 两钮同指 _load）
                  onPressed: () =>
                      ref.read(feedNotifierProvider.notifier).retry(),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        FeedStatus.data => ListView.builder(
            itemCount: state.articles.length,
            // 展示层若要关键字过滤，把这行换成 watch visibleArticlesProvider（清单 15-2）
            // 即可，本页四态渲染零改动——这正是派生层存在的意义
            itemBuilder: (BuildContext context, int index) {
              final Article article = state.articles[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(article.author.avatarUrl),
                ),
                title: Text(article.title),
                subtitle:
                    Text('${article.author.name} · ${article.publishedAt.year}'),
              );
            },
          ),
      },
    );
  }
}
