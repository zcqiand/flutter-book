import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:lab_management_system_flutter/core/auth/auth_controller.dart';
import 'package:lab_management_system_flutter/core/auth/auth_state.dart';
import 'package:lab_management_system_flutter/core/auth/providers.dart';
import 'package:lab_management_system_flutter/features/receipts/receipt_detail_page.dart';
import 'package:lab_management_system_flutter/generated/lab_shared_generated.dart'
    hide AuthState;

import '../../support/receipt_fixtures.dart';

/// 固定认证态桩（Phase 1 login_page_test 的 _SubmittingStubController 同款）。
class _AuthedNamedController extends AuthController {
  @override
  AuthState build() => const Authed(userId: 'u-1', displayName: '测试用户');
}

/// 无操作人身份：userId/displayName 双空（restore 乐观式合法态，AuthState 注）。
/// operator 解析链 displayName→userId 双空即 null → act 按钮全禁（ADR-0019）。
class _AuthedNoNameController extends AuthController {
  @override
  AuthState build() => const Authed();
}

void main() {
  late Dio dio;
  late DioAdapter adapter;
  var actCalls = 0;
  var detailCalls = 0;
  FlowActionRequest? actBody;

  Future<void> pumpDetail(
    WidgetTester tester, {
    bool withOperatorName = true,
  }) async {
    // act 按钮组/编辑入口挂在字段表 + 流程历史区之后的 ListView 尾部，默认
    // 800x600 逻辑试面装不下（sliver 懒装配视口外不进树，T4 同款）——拉高试面。
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(dio),
          authControllerProvider.overrideWith(
            withOperatorName
                ? _AuthedNamedController.new
                : _AuthedNoNameController.new,
          ),
        ],
        child: const MaterialApp(home: ReceiptDetailPage(receiptId: 'r-1')),
      ),
    );
  }

  setUp(() {
    dio = Dio();
    adapter = DioAdapter(dio: dio, matcher: const UrlRequestMatcher());
    actCalls = 0;
    detailCalls = 0;
    actBody = null;
    adapter.onGet('/api/receipts/r-1', (server) {
      // 计数放 reply 的 data callback（fetch 期 per-request）——handler 体只在
      // 注册期跑一次（T5/T6 配方），放 body 则 expect(detailCalls, 2) 必挂。
      server.reply(200, (RequestOptions options) {
        detailCalls++;
        return receiptJson();
      });
    });
    adapter.onGet(
      '/api/receipts/r-1/history',
      // 时间线留空：有流转记录时时间线也会渲染「提交/退回/撤回」文本，
      // 会和 act 按钮组的 find.text 撞车。
      (server) => server.reply(200, <dynamic>[]), // G-4：裸集合带 <dynamic>
    );
    adapter.onGet(
      '/api/samples',
      (server) => server.reply(200, samplesListJson([])),
    );
    adapter.onPost('/api/receipts/receiving/act', (server) {
      // 计数/捕获同放 data callback。本路径只有 POST 进来，无需滤 method。
      // wire 形状是 JSON object（StandardJsonPlugin 转换，T5 配方）。
      server.reply(200, (RequestOptions options) {
        actCalls++;
        actBody = standardSerializers.deserializeWith(
          FlowActionRequest.serializer,
          options.data as Map<String, dynamic>,
        )!;
        return <Map<String, Object>>[
          {'id': 'r-1', 'ok': true},
        ];
      });
    });
  });