// lib/core/mock_interceptor.dart
// 第 14 章教学链原件迁址留存：清单 14-2 的拦截器 mock 链原样迁到这里，
// 供第 14 章回执复抓与旧页面测试继续消费；类名 ApiClient 让位给
// 第 22 章契约链换代后的新 ApiClient（core/api_client.dart），改名 LegacyApiClient，
// 逻辑与清单 14-2 逐行等价。第 22 章起联调走本地 mock 服务（local_mock_server.dart）。
import 'dart:convert';

import 'package:dio/dio.dart';

/// 本地 Mock 的场景开关：改一个静态字段的值，三态页就切到对应形态
/// success=成功非空；empty=空列表；serverError=服务端 500
/// renamed=清单 14-6 翻车场景专用：后端已把 title 改名 article_title
enum MockScenario { success, empty, serverError, renamed }

class LegacyApiClient {
  LegacyApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        // baseUrl 指向一个本地假域：请求根本不出网，拦截器在发出前就 resolve，
        // 这是为了保证离线环境可跑、实测臂可复抓
        baseUrl: 'https://mock.local/api',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    _dio.interceptors.add(_buildTokenInterceptor());
    _dio.interceptors.add(MockInterceptor());
  }

  static final LegacyApiClient instance = LegacyApiClient._internal();

  late final Dio _dio;

  /// mock 场景开关：页面层或探针改这里即可演示三态，默认成功非空
  static MockScenario scenario = MockScenario.success;

  /// 缝位：token 注入拦截器，此处只搭缝，正式展开在后续章节
  Interceptor _buildTokenInterceptor() {
    return InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        // 演示串写死：真实工程里 token 来自登录态存储，取值方式后续章节交代
        options.headers['Authorization'] = 'Bearer demo-token';
        handler.next(options);
      },
    );
  }

  /// 拉取文章列表：只拿响应体，解析交给模型层（清单 14-8）
  Future<dynamic> fetchArticles() async {
    final Response<dynamic> response = await _dio.get<dynamic>('/articles');
    return response.data;
  }
}

/// 拦截 /articles 的本地 mock：命中后按场景开关直接 resolve，请求不出网
class MockInterceptor extends Interceptor {
  // 成功非空脚本：data 是数组，字段名与清单 14-8 的模型一一对应
  static const String _successJson = '''
  {
    "data": [
      {"id": 1, "title": "dio 拦截器：把横切关注点收进一条链",
       "author": {"id": 7, "name": "林晚风", "avatar_url": "https://cdn.example.com/avatar/7.png"},
       "published_at": "2026-01-05T08:30:00.000Z"},
      {"id": 2, "title": "json_serializable：让字段错误停在编译期",
       "author": {"id": 9, "name": "陈叙白", "avatar_url": "https://cdn.example.com/avatar/9.png"},
       "published_at": "2026-01-06T09:00:00.000Z"}
    ],
    "page": 1,
    "total": 2
  }
  ''';

  // 空列表脚本：结构与成功脚本完全一致，只有 data 换成空数组
  static const String _emptyJson = '''
  {"data": [], "page": 1, "total": 0}
  ''';

  // 翻车脚本：结构与成功脚本一致，字段按「后端改名」换成 article_title，
  // 仍按旧字段名 title 解析的代码（清单 14-6）在这里必炸
  static const String _renamedJson = '''
  {
    "data": [
      {"id": 1, "article_title": "dio 拦截器：把横切关注点收进一条链",
       "author": {"id": 7, "name": "林晚风", "avatar_url": "https://cdn.example.com/avatar/7.png"},
       "published_at": "2026-01-05T08:30:00.000Z"},
      {"id": 2, "article_title": "json_serializable：让字段错误停在编译期",
       "author": {"id": 9, "name": "陈叙白", "avatar_url": "https://cdn.example.com/avatar/9.png"},
       "published_at": "2026-01-06T09:00:00.000Z"}
    ],
    "page": 1,
    "total": 2
  }
  ''';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.path.contains('/articles')) {
      // 不归本拦截器管的请求原样放行
      handler.next(options);
      return;
    }
    // 这行日志就是清单 14-3 回执的实抓对象：能看到 token 已在链上游挂好
    // ignore: avoid_print
    print('MockInterceptor 命中 ${options.uri} '
        'Authorization=${options.headers['Authorization']} '
        'scenario=${LegacyApiClient.scenario.name}');

    switch (LegacyApiClient.scenario) {
      case MockScenario.success:
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            data: jsonDecode(_successJson) as Map<String, dynamic>,
            statusCode: 200,
          ),
        );
        break;
      case MockScenario.empty:
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            data: jsonDecode(_emptyJson) as Map<String, dynamic>,
            statusCode: 200,
          ),
        );
        break;
      case MockScenario.serverError:
        // 用 reject 携带 badResponse 类型的 DioException，状态码 500；
        // resolve 一个 500 状态码不会触发异常分支，错误态必须从 reject 走
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response<dynamic>(requestOptions: options, statusCode: 500),
          ),
        );
        break;
      case MockScenario.renamed:
        // 清单 14-6 翻车场景：resolve 改名后的响应体，旧字段名解析在运行时崩
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            data: jsonDecode(_renamedJson) as Map<String, dynamic>,
            statusCode: 200,
          ),
        );
        break;
    }
  }
}
