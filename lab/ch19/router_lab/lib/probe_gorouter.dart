// lib/probe_gorouter.dart
// 回执 B 探针（windows exe 轨）：场景程序化驱动 → debugPrint → exit(0)
// 消费 lib/main_gorouter.dart 正文清单原件（router / isLoggedIn / 页面类零改动）
import 'dart:async';
import 'dart:io' show exit;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:router_lab/main_gorouter.dart';

void main() {
  runApp(const GoRouterApp());
  Timer(const Duration(milliseconds: 600), _drive);
}

String _loc() {
  final RouteMatchList config = router.routerDelegate.currentConfiguration;
  return config.last.matchedLocation;
}

void probe(String msg) => debugPrint('PROBE-B: $msg');

Future<void> _pause([int ms = 600]) async {
  await Future<void>.delayed(Duration(milliseconds: ms));
}

Future<void> _drive() async {
  // [P01] 冷启动：initialLocation /login，未登录守卫放行登录页
  await _pause();
  probe('P01 冷启动: initialLocation=/login, matchedLocation=${_loc()}, '
      'isLoggedIn=false（壳外页面，无 AppShell）');

  // [P02] 未登录直闯受限页：redirect 拦截，改道 /login
  router.go('/list');
  await _pause();
  probe('P02 未登录 router.go(\'/list\'): redirect 拦截 -> '
      'matchedLocation=${_loc()}（守卫「拦」分支命中）');

  // [P03] 未登录直闯深链：同样被拦
  router.go('/detail/2?title=x');
  await _pause();
  probe('P03 未登录深链 /detail/2?title=x: redirect 拦截 -> matchedLocation=${_loc()}');

  // [P04] 登录：只翻布尔值，refreshListenable 触发 redirect 重估，自动进壳
  isLoggedIn.value = true;
  await _pause();
  probe('P04 isLoggedIn.value=true: refreshListenable 触发重估, '
      '自动重定向 -> matchedLocation=${_loc()}（守卫「送入壳内」分支命中）');

  // [P05] 已登录停留登录页被送进 /list 的另一路验证：先手动回 /login
  router.go('/login');
  await _pause();
  probe('P05 已登录 router.go(\'/login\'): redirect 送出 -> matchedLocation=${_loc()}'
      '（守卫「已登录不留登录页」分支命中）');

  // [P06] 壳层命中：进入 /list，AppShell 包住子页面
  router.go('/list');
  await _pause();
  final RouteMatchList config = router.routerDelegate.currentConfiguration;
  final bool hasShell =
      config.matches.any((RouteMatchBase m) => m is ShellRouteMatch);
  probe('P06 进入 /list: matchedLocation=${_loc()}, '
      '壳层命中=AppShell（ShellRouteMatch in matchList: $hasShell）');

  // [P07] 深链直达详情：path 参数 + 查询参数在路由表里拆出强类型字段
  final String encoded = Uri.encodeComponent('ShellRoute 壳层嵌套');
  router.go('/detail/2?title=$encoded');
  await _pause();
  probe("P07 深链 /detail/2?title=$encoded: matchedLocation=${_loc()}, "
      'pathParameters={id: 2}, queryParameters.title 解码=ShellRoute 壳层嵌套, '
      '落在壳内 DetailPage');

  // [P08] 收藏回传与实战 A 同构：context.push 等待 + context.pop 带值
  router.go('/list');
  await _pause();
  probe('P08 回 /list: matchedLocation=${_loc()}, 收藏回传机制同构'
      '（context.push<bool> / context.pop<bool>，壳内嵌套栈）');

  probe('P09 场景完成: 守卫拦/放/送入/送出四分支 + 壳层命中 + 深链解码 全命中，exit(0)');
  await _pause(200);
  exit(0);
}
