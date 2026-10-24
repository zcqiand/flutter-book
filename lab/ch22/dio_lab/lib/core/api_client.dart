// lib/core/api_client.dart
// 14 章的 ApiClient 在本章换代：本地 mock 拦截器退役，生成客户端上位。
// 手写的只有装配与消费，接口描述一行不写（红线二）。
// 生成物的类名与方法签名以当次生成为准，对齐位见占位标记。
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';

import 'package:dio_lab/core/session_guard.dart';
import 'package:dio_lab/core/token_interceptor.dart';
import 'package:dio_lab/core/token_provider.dart';
// 生成物 barrel：接口与模型全部从这里来，手写代码只认这一层
import 'package:dio_lab/generated/contract_generated.dart';

class ApiClient {
  ApiClient._internal(this.tokens) {
    final Dio dio = Dio(
      BaseOptions(
        // 联调对象是本地 mock 服务：基地址是运行时值，与 local_mock_server.dart
        // 的端口一处对一处（127.0.0.1 在场，零公网依赖）
        baseUrl: 'http://127.0.0.1:8321',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    // 链序：请求缝在前（token 注入），响应缝在后（401 会话守卫）
    dio.interceptors.add(TokenInterceptor(tokens));
    dio.interceptors.add(SessionGuardInterceptor(tokens));
    // 带缝的 dio 交给生成客户端：生成物管形状，拦截器管横切
    client = ContractGenerated(dio: dio); // <实测为准：CH22-05-生成客户端类名与构造签名对齐>
  }

  static final ApiClient instance = ApiClient._internal(MemoryTokenProvider());

  late final ContractGenerated client;
  // 类型名与登录方法签名以当次生成为准：<实测为准：CH22-06-生成客户端类型与方法签名对齐>
  final TokenProvider tokens;

  /// 登录：调生成客户端的接口方法，请求与响应模型都是生成物
  Future<void> login(String username, String password) async {
    final Response<LoginResponse> res = await client
        .getDefaultApi()
        .authLogin(
          loginRequest: LoginRequest(
            (LoginRequestBuilder b) => b
              ..username = username
              ..password = password,
          ),
        );
    await tokens.save(res.data!.token);
  }

  /// 拉取文章列表：返回生成模型，解析由生成器连带的序列化层完成
  Future<List<Article>> fetchArticles() async {
    final Response<BuiltList<Article>> res = await client.getDefaultApi().articlesList();
    return res.data?.toList() ?? const <Article>[];
  }
}
