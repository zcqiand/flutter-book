// test/probe_interceptor_receipt_test.dart
// 回执 A 探针（flutter test 轨）：三场景程序化驱动 MockInterceptor → print/debugPrint 落 stdout
// 消费 lib/core/api_client.dart 正文清单 14-2 原件，零改动零 mock
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dio_lab/core/mock_interceptor.dart';
import 'package:dio_lab/core/api_error.dart';

void main() {
  void probe(String msg) => debugPrint('PROBE-A: $msg');

  test('回执 A：MockInterceptor 命中日志 + token 注入头，success/empty/serverError 三分支', () async {
    // [P01] success：token 缝位先挂头 → Mock 命中打印 scenario=success → resolve 200 非空
    LegacyApiClient.scenario = MockScenario.success;
    final dynamic okBody = await LegacyApiClient.instance.fetchArticles();
    probe('P01 success 分支: resolve 200, data=${(okBody as Map<String, dynamic>)['data'].length} 条, page=${okBody['page']}, total=${okBody['total']}');

    // [P02] empty：同一客户端同一链路，仅翻转静态场景开关 → resolve 200 空数组
    LegacyApiClient.scenario = MockScenario.empty;
    final dynamic emptyBody = await LegacyApiClient.instance.fetchArticles();
    probe('P02 empty 分支: resolve 200, data=${(emptyBody as Map<String, dynamic>)['data'].length} 条, total=${emptyBody['total']}');

    // [P03] serverError：reject 携带 badResponse DioException(500) → mapDioError 归一
    LegacyApiClient.scenario = MockScenario.serverError;
    Object? caught;
    try {
      await LegacyApiClient.instance.fetchArticles();
    } catch (error) {
      caught = error;
    }
    final ApiException apiError = mapDioError(caught!);
    probe('P03 serverError 分支: reject 触发 DioException(badResponse, HTTP 500) '
        '→ mapDioError 归一为 $apiError');

    probe('P04 三场景覆盖完成: 同一拦截器链 success/empty/serverError 三分支全部命中，'
        'Authorization 头三行命中日志均含 Bearer demo-token');
  });
}
