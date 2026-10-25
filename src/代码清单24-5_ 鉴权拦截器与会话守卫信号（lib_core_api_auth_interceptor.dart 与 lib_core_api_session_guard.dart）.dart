// ===== lib/core/api/auth_interceptor.dart =====
import 'package:dio/dio.dart';

import 'session_guard.dart';

/// 请求侧：非空 token 加 `Authorization: Bearer <token>`；
/// 响应侧：401 且非 auth 端点自身 → guard.fire()（清会话回登录页）再原样上抛。
/// auth 路径排除：登录自身 401（错凭据）不能触发会话失效回路（react 先例）。
/// 本层不感知 Widget/路由。
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.readAccessToken, required this.guard});

  final Future<String?> Function() readAccessToken;
  final SessionGuard guard;

  /// auth 端点自身不参与 401 会话失效（react http-client 排除段同形）。
  static bool isAuthPath(String path) => path.contains('/api/auth/');

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    String? token;
    try {
      token = await readAccessToken();
    } catch (_) {
      // 存储读失败不挂死请求：无头继续，服务端 401 经 onError 缝自愈清会话（R6 形态）。
      token = null;
    }
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 &&
        !isAuthPath(err.requestOptions.path)) {
      guard.fire();
    }
    handler.next(err);
  }
}

// ===== lib/core/api/session_guard.dart =====
/// 401 会话失效回调持有器：controller 依赖 ApiClient 发请求，拦截器 401 时
// ……（节略）
class SessionGuard {
  void Function()? onUnauthorized;
  void fire() => onUnauthorized?.call();
}