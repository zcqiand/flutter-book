// lib/features/article_feed_page.dart
// 三态页：加载/空态/错误三个异常分支加一个正常数据态，setState 驱动
import 'package:flutter/material.dart';

import 'package:dio_lab/core/api_client.dart';
import 'package:dio_lab/core/api_error.dart';
import 'package:dio_lab/models/article.dart';

/// data 是第四态，即正常态；正文说的三态指前三个异常分支
enum FeedStatus { loading, empty, error, data }

class ArticleFeedPage extends StatefulWidget {
  const ArticleFeedPage({super.key});

  @override
  State<ArticleFeedPage> createState() => _ArticleFeedPageState();
}

class _ArticleFeedPageState extends State<ArticleFeedPage> {
  FeedStatus _status = FeedStatus.loading;
  List<Article> _articles = const <Article>[];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // 每次加载先回 loading：让「重新加载」按钮按下后页面有明确反馈
    setState(() {
      _status = FeedStatus.loading;
    });
    try {
      final dynamic body = await ApiClient.instance.fetchArticles();
      final ApiPage<Article> page = ApiPage<Article>.fromJson(
        body as Map<String, dynamic>,
        Article.fromJson,
      );
      final List<Article> articles = page.data;
      setState(() {
        if (articles.isEmpty) {
          _status = FeedStatus.empty;
        } else {
          _articles = articles;
          _status = FeedStatus.data;
        }
      });
    } catch (error) {
      // 任何异常先过 mapDioError 归一，页面只面对 ApiException 一种错误
      final ApiException apiError = mapDioError(error);
      setState(() {
        _status = FeedStatus.error;
        _errorMessage = apiError.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文章列表')),
      // 演示方法：改 ApiClient.scenario 后热重载或重启即可逐一切换三态
      // success 对应数据态，empty 对应空态，serverError 对应错误态
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
            itemCount: _articles.length,
            itemBuilder: (BuildContext context, int index) {
              final Article article = _articles[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(article.author.avatarUrl),
                ),
                title: Text(article.title),
                subtitle: Text('${article.author.name} · ${article.publishedAt.year}'),
              );
            },
          ),
      },
    );
  }
}