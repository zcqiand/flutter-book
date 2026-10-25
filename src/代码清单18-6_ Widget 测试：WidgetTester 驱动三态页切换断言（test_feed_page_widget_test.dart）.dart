// test/feed_page_widget_test.dart
// Widget 测试：WidgetTester 驱动三态页原件，三段用例跑完四态断言；
// 数据层用真实 MockFeedRepository，场景切换靠静态开关而非换替身
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod_lab/core/feed_providers.dart';
import 'package:riverpod_lab/features/article_feed_page.dart';

// 1×1 透明 PNG（base64）：头像 NetworkImage 的假响应，防测试轨图片异常
final Uint8List _kPngBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');

// 头像网络请求拦截三件套：与 ch15 清单 15-6 同款写法压缩到必要行，
// debugNetworkImageHttpClientProvider 换掉后 NetworkImage 不再真出网
class _FakeHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      Future<HttpClientRequest>.value(_FakeRequest());
}

class _FakeRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<HttpClientResponse> close() =>
      Future<HttpClientResponse>.value(_FakeResponse());
}

class _FakeResponse implements HttpClientResponse {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kPngBytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    Function? onDone,
    bool? cancelOnError,
  }) {
    return Stream<Uint8List>.fromIterable(<Uint8List>[_kPngBytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

Future<void> pumpFeedPage(WidgetTester tester) async {
  // 显式挂载真实 mock 仓库：数据层入口一处写死；
  // 三态切换不靠换替身，靠 MockFeedRepository.scenario 静态开关
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        feedRepositoryProvider.overrideWithValue(const MockFeedRepository()),
      ],
      child: const MaterialApp(home: ArticleFeedPage()),
    ),
  );
}

void main() {
  setUp(() {
    // 静态开关跨测试残留：不复位的话，上一个用例切过的场景会污染下一个
    MockFeedRepository.scenario = MockScenario.success;
    debugNetworkImageHttpClientProvider = () => _FakeHttpClient();
  });

  tearDown(() {
    debugNetworkImageHttpClientProvider = null;
  });

  testWidgets('第一段：loading 首帧与 success 场景的 data 态', (tester) async {
    await pumpFeedPage(tester);

    // 首拉由 FeedNotifier.build 自动发起：首帧必是 loading 分支
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // mock 的 300ms 延迟靠 pumpAndSettle 逐帧推进推完，data 态才落定
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.textContaining('拦截器'), findsOneWidget);
    expect(find.textContaining('json_serializable'), findsOneWidget);

    // painting 调试变量在 testWidgets 体内终检（早于 tearDown），必须显式复位
    debugNetworkImageHttpClientProvider = null;
  });

  testWidgets('第二段：empty 场景落空态与重新加载按钮', (tester) async {
    // 场景在挂载前切好：自动首拉发生在首次 watch 之后，此刻改开关来得及生效
    MockFeedRepository.scenario = MockScenario.empty;
    await pumpFeedPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('暂无文章'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '重新加载'), findsOneWidget);

    debugNetworkImageHttpClientProvider = null;
  });

  testWidgets('第三段：serverError 场景落错误态与重试按钮', (tester) async {
    MockFeedRepository.scenario = MockScenario.serverError;
    await pumpFeedPage(tester);
    await tester.pumpAndSettle();

    // 错误文案是 FeedNotifier 里归一后的固定话术，不是原始异常文本
    expect(find.text('加载失败，请稍后重试'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '重试'), findsOneWidget);

    debugNetworkImageHttpClientProvider = null;
  });
}