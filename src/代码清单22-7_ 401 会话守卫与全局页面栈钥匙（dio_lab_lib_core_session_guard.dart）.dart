// lib/core/session_guard.dart
// 401 会话守卫：响应失败兜底缝。职责单一：认出 401，清会话，送回登录页
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:dio_lab/core/token_provider.dart';

/// 全局页面栈钥匙：MaterialApp 侧挂上它（navigatorKey: navigatorKey），
/// 拦截器在 Widget 树之外也能操作页面栈
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SessionGuardInterceptor extends Interceptor {
  SessionGuardInterceptor(this._tokens);

  final TokenProvider _tokens;

  // 并发请求可能同时吃 401：标志位保证同一批并发失效窗口内只送一次，
  // 否则登录页会被连跳数遍
  bool _handling = false;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_handling) {
      _handling = true;
      // 第一步：清会话。失效凭证留在缝里，下次请求还会带着它出门
      await _tokens.clear();
      // 第二步：清栈落登录页。pushAndRemoveUntil 第二个参数是栈保留判据，
      // 恒返回 false 意味着旧页面全部出栈，栈里只剩登录页
      unawaited(navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      ));
      // 发起跳转即解锁：新会话里的 401 仍能触发守卫
      _handling = false;
    }
    // 兜底不吞错误：错误照常沿链放行，页面捕获后归一成 ApiException
    handler.next(err);
  }
}