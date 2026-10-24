// lib/core/feed_notifier.dart
// 状态收敛：ch14 清单 14-5 散落在 State 里的一个枚举三个字段三处 setState，
// 全部搬进 FeedNotifier 一处，页面从此只读状态不写状态
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_lab/core/feed_providers.dart';
import 'package:riverpod_lab/models/article.dart';

/// data 是第四态，即正常态；正文说的三态指前三个异常分支
/// 枚举值与 ch14 清单 14-5 逐字一致：状态语义一行没改，改的只是住址
enum FeedStatus { loading, empty, error, data }

/// 不可变状态：一次状态替换=整块换一个新 FeedState，没有逐字段改的中间态
class FeedState {
  const FeedState({
    this.status = FeedStatus.loading,
    this.articles = const <Article>[],
    this.errorMessage = '',
  });

  final FeedStatus status;
  final List<Article> articles;
  final String errorMessage;

  /// copyWith：只换传入的字段，其余原样保留——不可变类的标准拼装法
  FeedState copyWith({
    FeedStatus? status,
    List<Article>? articles,
    String? errorMessage,
  }) {
    return FeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 业务状态收敛入口：FeedNotifier 持有 FeedState，谁 watch 谁重建
class FeedNotifier extends Notifier<FeedState> {
  @override
  FeedState build() {
    // build 即首拉入口：Riverpod Provider 首次被 watch 时触发，
    // 页面不再需要 initState 里的手动首拉（对照清单 14-5 的 initState + _load）
    // build 必须同步返回初始态，异步首拉发起后不在此等待，结果经 state= 落回
    unawaited(load());
    return const FeedState(status: FeedStatus.loading);
  }

  /// ch14 清单 14-5 的三处 setState 在这里收拢成一次状态替换：
  /// 每个分支整块换掉 FeedState，不存在「改了一半」的中间态
  Future<void> load() async {
    // 先置 loading：让「重新加载」按钮按下后页面有明确反馈（语义同 ch14）
    state = const FeedState(status: FeedStatus.loading);
    try {
      // 数据源从数据层 Riverpod Provider 取，本类不 new 任何实现
      final List<Article> articles =
          await ref.read(feedRepositoryProvider).fetchArticles();
      if (articles.isEmpty) {
        state = const FeedState(status: FeedStatus.empty);
      } else {
        state = FeedState(status: FeedStatus.data, articles: articles);
      }
    } catch (_) {
      // 错误归一与 ch14 清单 14-4 的 mapDioError 同构：异常先翻成可读消息再落态。
      // 本工程 mock 自持不出网，没有 DioException 可拆，简版给固定文案；
      // 接真实网络后这里换回完整映射函数，落态写法不变
      state = const FeedState(
        status: FeedStatus.error,
        errorMessage: '加载失败，请稍后重试',
      );
    }
  }

  /// retry 与 load 走同一条路径：对应 ch14 清单 14-5 两钮同指 _load 的语义
  Future<void> retry() => load();
}
