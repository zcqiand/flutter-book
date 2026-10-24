// test/fake_avatar_http.dart
// 测试专用假头像 HTTP 栈：flutter_test 沙箱对一切 HTTP 返回 400，
// 数据态 ListTile 的 NetworkImage 加载头像必炸出 unexpected exception。
// 本文件给 NetworkImage 挂一个返回 1×1 透明 PNG 的假客户端，只服务测试轨。
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

// 1×1 透明 PNG（base64）
final Uint8List _kPngBytes =
    base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');

/// 在 testWidgets 的 setUp 里调用一次即可
void installFakeAvatarHttp() {
  debugNetworkImageHttpClientProvider = () => _FakeHttpClient();
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) => Future<HttpClientRequest>.value(_FakeRequest());
}

class _FakeRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() => Future<HttpClientResponse>.value(_FakeResponse());
}

class _FakeResponse extends Fake implements HttpClientResponse {
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
