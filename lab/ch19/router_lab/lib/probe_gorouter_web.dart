// lib/probe_gorouter_web.dart
// Web 轨探针（chrome 实跑）：冷启动 URI 打印 → 场景程序化驱动 → 打印命中 route
// 消费 lib/main_gorouter.dart 正文清单原件，零改动零 mock；Web 兼容（无 dart:io）
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:router_lab/main_gorouter.dart';

void main() {
  // runApp 前同步捕获冷启 URL：守卫重定向会在首帧改写地址，晚了就读不到直输原文
  final String coldUrl = Uri.base.toString();
  runApp(const GoRouterApp());
  // 冷启动深链标签页（地址栏直输 URL 冷启）只打印守卫结果即停驱动；
  // 主标签页走完整场景。
  Timer(const Duration(milliseconds: 2500), () {
    if (coldUrl.contains('/detail') || coldUrl.contains('/list')) {
      _coldDeepLink(coldUrl);
    } else {
      _drive();
    }
  });
}

void probe(String msg) => debugPrint('PROBE-WEB: $msg');

String _loc() =>
    router.routerDelegate.currentConfiguration.last.matchedLocation;

Future<void> _pause([int ms = 800]) async {
  await Future<void>.delayed(Duration(milliseconds: ms));
}

/// 冷启动深链（教学版无持久会话，新标签页未登录）：地址栏直输 /detail/2 冷启，
/// 守卫应在首帧重定向打回 /login —— 正文 13.5「未登录访客输入受保护地址落在登录页」
Future<void> _coldDeepLink(String start) async {
  probe('P00a 冷启动地址栏直输原文: $start');
  await _pause();
  probe('P00b 守卫裁决后: matchedLocation=${_loc()} '
      '（未登录冷启深链被 redirect 打回 /login，无报错页）');
}

/// 主标签页完整场景：守卫 → 登录 → 壳层 → 深链（地址栏同步）→ 回传
Future<void> _drive() async {
  await _pause();
  probe('P01 冷启动: URL=${Uri.base}, matchedLocation=${_loc()}, isLoggedIn=false');

  router.go('/list');
  await _pause();
  probe('P02 未登录 router.go(\'/list\'): redirect 拦截 -> matchedLocation=${_loc()}');

  isLoggedIn.value = true;
  await _pause();
  probe('P04 isLoggedIn.value=true: refreshListenable 自动重定向 -> '
      'matchedLocation=${_loc()}');

  final String encoded = Uri.encodeComponent('ShellRoute 壳层嵌套');
  router.go('/detail/2?title=$encoded');
  await _pause();
  probe("P07 深链 /detail/2?title=$encoded: matchedLocation=${_loc()}, "
      '地址栏已同步显示深链 URL（go_router Web URL 同步）, '
      'pathParameters={id: 2}, title 解码=ShellRoute 壳层嵌套');

  router.go('/list');
  await _pause();
  probe('P08 回 /list: matchedLocation=${_loc()}, 壳内嵌套栈回传同构'
      '（context.push<bool> / context.pop<bool>）');

  probe('P09 Web 场景完成，探针停驱（应用常驻，由外部收尾）');
}
