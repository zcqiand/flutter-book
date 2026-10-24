// ============ lib/storage/token_store.dart（flutter_secure_storage token 段）============
// 安全红线：token 属敏感数据，只进 flutter_secure_storage（系统级加密存储），
// 严禁落 shared_preferences（明文键值文件，root 与备份场景可直接读走）
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  // 保持最简薄封装：ch24 的 TokenStore 在此基础上接刷新逻辑，API 面不变
  const TokenStore();

  static const String _kToken = 'guard_lab.auth.token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> write(String token) {
    return _storage.write(key: _kToken, value: token);
  }

  Future<String?> read() {
    return _storage.read(key: _kToken);
  }

  Future<void> delete() {
    return _storage.delete(key: _kToken);
  }

  Future<void> clear() {
    return _storage.deleteAll();
  }
}
