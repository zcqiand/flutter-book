// test/article_feed_page_test.dart
// 三态页测试：加载/空态/错误/数据四态 UI 分支 + 空态与错误态的回拉按钮
// 消费 lib/features/article_feed_page.dart 正文清单 14-5 原件，零改动
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dio_lab/core/mock_interceptor.dart';
import 'package:dio_lab/features/article_feed_page.dart';

import 'fake_avatar_http.dart';

void main() {
  setUp(installFakeAvatarHttp);
  // painting 调试变量在 testWidgets 体内终检（早于 tearDown），
  // 每个测试体末尾必须显式复位，否则 flutter_test 报 invariant 失败
  void resetFakeAvatarHttp() {
    debugNetworkImageHttpClientProvider = null;
  }

  testWidgets('success 场景：loading 态先现，数据态 ListView 落 2 条', (tester) async {
    LegacyApiClient.scenario = MockScenario.success;
    await tester.pumpWidget(const MaterialApp(home: ArticleFeedPage()));

    // 加载态：请求在途，转圈可见
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    // 数据态：两条文章落列表
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('dio 拦截器：把横切关注点收进一条链'), findsOneWidget);
    expect(find.text('json_serializable：让字段错误停在编译期'), findsOneWidget);
    resetFakeAvatarHttp();
  });

  testWidgets('empty 场景：空态文案 + 重新加载按钮回拉后仍在空态', (tester) async {
    LegacyApiClient.scenario = MockScenario.empty;
    await tester.pumpWidget(const MaterialApp(home: ArticleFeedPage()));
    await tester.pumpAndSettle();

    expect(find.text('暂无文章'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '重新加载'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);

    // 回拉：重新加载 → loading → 仍为空态（empty 脚本不变）
    await tester.tap(find.widgetWithText(ElevatedButton, '重新加载'));
    await tester.pump(); // _load 先 setState 切 loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('暂无文章'), findsOneWidget);
    resetFakeAvatarHttp();
  });

  testWidgets('serverError 场景：错误态文案 HTTP 500 + 重试按钮回拉仍入错误态', (tester) async {
    LegacyApiClient.scenario = MockScenario.serverError;
    await tester.pumpWidget(const MaterialApp(home: ArticleFeedPage()));
    await tester.pumpAndSettle();

    // mapDioError 把 badResponse(500) 归一成可读文案
    expect(find.text('服务返回异常（HTTP 500）'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '重试'), findsOneWidget);

    // 回拉：重试 → loading → 错误态（reject 500 不变）
    await tester.tap(find.widgetWithText(ElevatedButton, '重试'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('服务返回异常（HTTP 500）'), findsOneWidget);
    resetFakeAvatarHttp();
  });
}
