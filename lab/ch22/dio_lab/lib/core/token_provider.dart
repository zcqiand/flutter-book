// lib/core/token_provider.dart
// 令牌存取缝：token 从哪来、存到哪、何时清，都收在这层抽象后面
abstract class TokenProvider {
  Future<String?> read();
  Future<void> save(String token);
  Future<void> clear();
}

// 教学实现：内存版，进程在 token 在。生产归属安全级存储
// （选型判据回指 17.4/17.5），第 24 章真仓落双端安全存储缝
class MemoryTokenProvider implements TokenProvider {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> save(String token) async {
    _token = token;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }
}
