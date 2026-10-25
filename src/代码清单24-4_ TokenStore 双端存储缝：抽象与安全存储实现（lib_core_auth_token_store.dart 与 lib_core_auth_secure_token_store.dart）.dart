// ===== lib/core/auth/token_store.dart =====
/// token 存储缝：生产绑 SecureTokenStore（flutter_secure_storage），
abstract class TokenStore {
  /// 两键名常量：生产写入用，杜绝键名漂移。
  static const String accessKey = 'lab.accessToken';
  static const String refreshKey = 'lab.refreshToken';

  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();

  /// refreshToken 可空（lab 契约 LoginResponse.refreshToken optional）：
  /// null 时只写 access 键、不动旧 refresh 值。
  Future<void> save({required String accessToken, String? refreshToken});
  Future<void> clear();
}

// ===== lib/core/auth/secure_token_store.dart =====
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_store.dart';

/// 生产实现：Android Keystore 级；Web 端 localStorage 级（与 react 参照同级，不夸大）。
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: TokenStore.accessKey);

  @override
  Future<String?> readRefreshToken() =>
      _storage.read(key: TokenStore.refreshKey);

  @override
  Future<void> save({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: TokenStore.accessKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: TokenStore.refreshKey, value: refreshToken);
    }
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: TokenStore.accessKey);
    await _storage.delete(key: TokenStore.refreshKey);
  }
}