// lib/core/token_interceptor.dart
// token 注入拦截器：14.1 只搭缝的地方，本章长出实体。
// 职责单一：请求发出前把 Authorization 头挂上，其余一概不管
// ignore_for_file: avoid_print
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
    // debug 日志：清单 22-5 回执实抓位（教学版直印；生产归日志框架）
    print('[token-interceptor] ${options.method} ${options.uri} '
        'Authorization=${options.headers['Authorization']}');
    handler.next(options);
  }
}
