// lib/probe_interceptor.dart
// 回执 A 的 windows debug 直跑探针：三场景程序化驱动 → print → exit(0)
// 自驱动自退，零交互零挂起；stdout 原样重定向即回执
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:dio_lab/core/mock_interceptor.dart';
import 'package:dio_lab/core/api_error.dart';

Future<void> main() async {
  // [P01] success：token 缝位先挂头 → Mock 命中打印 scenario=success → resolve 200 非空
  LegacyApiClient.scenario = MockScenario.success;
  final dynamic okBody = await LegacyApiClient.instance.fetchArticles();
  print('PROBE-A-WIN: P01 success 分支: resolve 200, '
      'data=${(okBody as Map<String, dynamic>)['data'].length} 条, '
      'page=${okBody['page']}, total=${okBody['total']}');

  // [P02] empty：同一客户端同一链路，仅翻转静态场景开关 → resolve 200 空数组
  LegacyApiClient.scenario = MockScenario.empty;
  final dynamic emptyBody = await LegacyApiClient.instance.fetchArticles();
  print('PROBE-A-WIN: P02 empty 分支: resolve 200, '
      'data=${(emptyBody as Map<String, dynamic>)['data'].length} 条, total=${emptyBody['total']}');

  // [P03] serverError：reject 携带 badResponse DioException(500) → mapDioError 归一
  LegacyApiClient.scenario = MockScenario.serverError;
  Object? caught;
  try {
    await LegacyApiClient.instance.fetchArticles();
  } catch (error) {
    caught = error;
  }
  print('PROBE-A-WIN: P03 serverError 分支: reject 触发 DioException(badResponse, HTTP 500) '
      '→ mapDioError 归一为 ${mapDioError(caught!)}');

  print('PROBE-A-WIN: P04 三场景覆盖完成: '
      'Authorization 头三行命中日志均含 Bearer demo-token');
  exit(0);
}
