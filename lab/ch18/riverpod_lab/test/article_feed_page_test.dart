// test/article_feed_page_test.dart
// 冒烟测试（widget test 轨）：消费正文清单 15-6 页面原件与清单 15-3/15-2 状态链，
// 验证 Riverpod 重构版首拉链路：watch 即 loading → mock 300ms → data 态 2 条
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:riverpod_lab/features/article_feed_page.dart';

// 1×1 透明 PNG（base64）：头像 NetworkImage 的假响应，防测试轨图片异常
final Uint8List _kPngBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');

class _FakeHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<HttpClientRequest> getUrl(Uri url) => Future<HttpClientRequest>.value(_FakeRequest());
}

class _FakeRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<HttpClientResponse> close() => Future<HttpClientResponse>.value(_FakeResponse());
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
    void Function()? onDone,
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

void main() {
  setUp(() {
    debugNetworkImageHttpClientProvider = () => _FakeHttpClient();
  });

  tearDown(() {
    debugNetworkImageHttpClientProvider = null;
  });

  testWidgets('Riverpod 重构版三态页：首拉 loading → data 态 2 条', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ArticleFeedPage())),
    );

    // 首拉由 FeedNotifier.build 承载：首帧即 loading 分支
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // mock 300ms 延迟后落 data 态：ListView 渲染 2 条
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.textContaining('拦截器'), findsOneWidget);
    expect(find.textContaining('json_serializable'), findsOneWidget);

    // painting 调试变量在 testWidgets 体内终检（早于 tearDown），必须显式复位
    debugNetworkImageHttpClientProvider = null;
  });
}
