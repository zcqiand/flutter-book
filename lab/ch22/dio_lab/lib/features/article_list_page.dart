// lib/features/article_list_page.dart
// 受保护文章列表页：第 22 章闭环的数据态页。数据来自生成客户端
// （Article 模型是生成物），链上挂 token 注入缝与 401 会话守卫缝
import 'package:flutter/material.dart';

import 'package:dio_lab/core/api_client.dart';
import 'package:dio_lab/core/api_error.dart';
import 'package:dio_lab/core/local_mock_server.dart';
import 'package:dio_lab/generated/model/article.dart';

/// data 是第四态，即正常态；三态指前三个异常分支（口径同 14 章）
enum FeedStatus { loading, empty, error, data }

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  FeedStatus _status = FeedStatus.loading;
  List<Article> _articles = const <Article>[];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _status = FeedStatus.loading;
    });
    try {
      // 返回值已是生成模型：解析由生成器连带的序列化层完成，页面零解析
      final List<Article> articles = await ApiClient.instance.fetchArticles();
      setState(() {
        if (articles.isEmpty) {
          _status = FeedStatus.empty;
        } else {
          _articles = articles;
          _status = FeedStatus.data;
        }
      });
    } catch (error) {
      // 守卫兜底不吞错误：401 归一后照常到这里，页面只管提示
      final ApiException apiError = mapDioError(error);
      if (!mounted) {
        return;
      }
      setState(() {
        _status = FeedStatus.error;
        _errorMessage = apiError.message;
      });
    }
  }

  /// 破坏性实验入口：先在 mock 服务端把当前 token 标记吊销，再拉一次列表
  void _revokeAndReload() {
    LocalMockServer.instance.revokeCurrentToken();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文章列表')),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey<String>('revoke-and-reload'),
        onPressed: _status == FeedStatus.data ? _revokeAndReload : null,
        label: const Text('吊销并重拉'),
        icon: const Icon(Icons.gpp_bad_outlined),
      ),
      body: switch (_status) {
        FeedStatus.loading => const Center(child: CircularProgressIndicator()),
        FeedStatus.empty => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('暂无文章'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('重新加载'),
                ),
              ],
            ),
          ),
        FeedStatus.error => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_errorMessage),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        FeedStatus.data => ListView.builder(
            key: const ValueKey<String>('article-list'),
            itemCount: _articles.length,
            itemBuilder: (BuildContext context, int index) {
              final Article article = _articles[index];
              return ListTile(
                title: Text(article.title),
                subtitle: Text(article.authorName),
              );
            },
          ),
      },
    );
  }
}
