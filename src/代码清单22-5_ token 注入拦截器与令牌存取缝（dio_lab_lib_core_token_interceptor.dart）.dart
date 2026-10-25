// lib/core/token_interceptor.dart
// token 注入拦截器：14.1 只搭缝的地方，本章长出实体。
// 职责单一：请求发出前把 Authorization 头挂上，其余一概不管
import 'package:dio/dio.dart';

import 'package:dio_lab/core/token_provider.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor(this._tokens);

  final TokenProvider _tokens;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 读不到 token 就原样放行：登录请求自己没凭证，不能被缝拦死
    final String? token = await _tokens.read();
    if (token != null && token.isNotEmpty) {
      // Bearer 是 HTTP 鉴权凭证的标准形态：头名 Authorization，值以 Bearer 起头
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// lib/core/token_provider.dart
// 令牌存取缝：token 从哪来、存到哪、何时清，都收在这层抽象后面
abstract class TokenProvider {
  Future<String?> read();
  Future<void> save(String token);
  Future<void> clear();
}

// 教学实现：内存版，进程在 token 在。生产归属安全级存储
// （选型判据回指 17.4/17.5），第 24 章真仓落双端安全存储缝
class MemoryTokenProvider implements TokenProvider {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> save(String token) async {
    _token = token;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }
}