// lib/core/local_mock_server.dart
// 第 22 章联调对象：本地 mock 服务（dart:io HttpServer，127.0.0.1 在场，
// 零公网依赖）。契约形状之外的事它不做：/auth/login 签发教学版 token，
// /articles 验 Authorization 头，/dev/revoke 是破坏性实验的吊销开关。
// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class LocalMockServer {
  LocalMockServer._();

  static final LocalMockServer instance = LocalMockServer._();

  /// 端口与 api_client.dart 的 baseUrl 一处对一处：写死保证回执可复抓
  static const int port = 8321;
  static const String baseUrl = 'http://127.0.0.1:$port';

  HttpServer? _server;
  String? _issuedToken;
  String? _revokedToken;

  bool get isRunning => _server != null;

  Future<void> start() async {
    if (_server != null) {
      return;
    }
    _server = await HttpServer.bind('127.0.0.1', port);
    print('[mock-server] listening on http://127.0.0.1:$port');
    _server!.listen(_handle);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  /// 破坏性实验开关：把当前 token 标记吊销，下一次 /articles 必吃 401
  void revokeCurrentToken() {
    _revokedToken = _issuedToken;
    print('[mock-server] /dev/revoke 当前 token 已标记吊销');
  }

  Future<void> _handle(HttpRequest req) async {
    final String path = req.uri.path;
    if (req.method == 'POST' && path == '/auth/login') {
      final dynamic body =
          jsonDecode(await utf8.decoder.bind(req).join()) as Map<dynamic, dynamic>;
      final String? username = body['username'] as String?;
      final String? password = body['password'] as String?;
      final bool ok =
          (username != null && username.isNotEmpty) && (password != null && password.isNotEmpty);
      if (ok) {
        _issuedToken = 'local-mock-${DateTime.now().microsecondsSinceEpoch}';
        _revokedToken = null; // 新登录签发新会话，旧吊销标记随之清零
        print('[mock-server] POST /auth/login 200 签发 token=$_issuedToken');
        _json(req, 200, <String, String>{'token': _issuedToken!});
      } else {
        print('[mock-server] POST /auth/login 401 凭证缺失或为空');
        _json(req, 401, <String, String>{'message': 'bad credentials'});
      }
      return;
    }
    if (req.method == 'GET' && path == '/articles') {
      final String auth = req.headers.value(HttpHeaders.authorizationHeader) ?? '';
      final bool valid = auth == 'Bearer $_issuedToken' && _revokedToken != _issuedToken;
      // 服务端命中行：清单 22-5 回执实抓位（同一请求带着同一形态的头到达）
      print('[mock-server] GET /articles 命中 Authorization=$auth '
          'verdict=${valid ? '200 验头通过' : '401 token 不被认账'}');
      if (!valid) {
        _json(req, 401, <String, String>{'message': 'token invalid'});
        return;
      }
      _json(req, 200, <Map<String, dynamic>>[
        <String, dynamic>{'id': 1, 'title': '契约先行：TypeSpec 把接口约定钉死一次', 'authorName': '林晚风'},
        <String, dynamic>{'id': 2, 'title': '生成物上位：手写接口层整层退役', 'authorName': '陈叙白'},
      ]);
      return;
    }
    _json(req, 404, <String, String>{'message': 'not found'});
  }

  void _json(HttpRequest req, int status, Object data) {
    req.response.statusCode = status;
    req.response.headers.contentType = ContentType.json;
    req.response.write(jsonEncode(data));
    req.response.close();
  }
}
