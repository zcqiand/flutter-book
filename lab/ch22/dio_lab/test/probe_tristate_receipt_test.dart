// test/probe_tristate_receipt_test.dart
// 回执 D 探针（flutter test 轨）：三态页 loading/empty/error 三态逐态实抓
// 每态一条 debugPrint 证据：页面切换 + 该态 UI 分支命中 + 回拉按钮闭环
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

  void probe(String msg) => debugPrint('PROBE-D: $msg');

  testWidgets('回执 D：三态页 loading/empty/error 三态 UI 分支逐态实抓', (tester) async {
    // [P01] loading 态：initState 即发请求，转圈分支命中
    LegacyApiClient.scenario = MockScenario.success;
    await tester.pumpWidget(const MaterialApp(home: ArticleFeedPage(key: ValueKey<String>('loading'))));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    probe('P01 loading 态命中: CircularProgressIndicator ×1（initState 发请求，请求在途）');
    await tester.pumpAndSettle(); // 先把本页请求续体抽干，再换场景，防旧页 setState 毒化后续帧

    // [P02] 切 empty 场景重建页面：空态分支命中
    LegacyApiClient.scenario = MockScenario.empty;
    await tester.pumpWidget(const MaterialApp(home: ArticleFeedPage(key: ValueKey<String>('empty'))));
    await tester.pumpAndSettle();
    expect(find.text('暂无文章'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '重新加载'), findsOneWidget);
    probe('P02 empty 态命中: 「暂无文章」+ 重新加载按钮（空列表分支，ListView 不出现）');

    // [P03] 切 serverError 场景重建页面：错误态分支命中
    LegacyApiClient.scenario = MockScenario.serverError;
    await tester.pumpWidget(const MaterialApp(home: ArticleFeedPage(key: ValueKey<String>('error'))));
    await tester.pumpAndSettle();
    expect(find.text('服务返回异常（HTTP 500）'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '重试'), findsOneWidget);
    probe('P03 error 态命中: 「服务返回异常（HTTP 500）」+ 重试按钮（reject 500 → mapDioError 归一）');

    // [P04] 错误态回拉：重试按钮 → loading 分支再次命中（错误态 → 加载态转场）
    await tester.tap(find.widgetWithText(ElevatedButton, '重试'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    probe('P04 重试回拉命中: 错误态点重试 → loading 转圈分支再次出现（与图 14-2 重试边一致）');
    await tester.pumpAndSettle(); // 抽干重试请求续体，再换场景

    // [P05] 数据态收官：success 场景重建，ListView 分支命中 2 条
    LegacyApiClient.scenario = MockScenario.success;
    await tester.pumpWidget(const MaterialApp(home: ArticleFeedPage(key: ValueKey<String>('data'))));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    probe('P05 data 态命中: ListView ×1 落 2 条文章（第四态，success 场景 200 非空）');

    probe('P06 三态页探针完成: loading/empty/error 三态各一条 debugPrint 证据 + 回拉转场 + 数据态，四态分支全部命中');
    resetFakeAvatarHttp();
  });
}
