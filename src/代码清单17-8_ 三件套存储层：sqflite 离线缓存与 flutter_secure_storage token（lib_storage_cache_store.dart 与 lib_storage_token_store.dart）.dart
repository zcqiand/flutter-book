// ============ lib/storage/cache_store.dart（sqflite 离线缓存段）============
// 离线缓存口径：接口返回的列表先落 SQLite，断网时也能从库里读出上一次的数据
import 'package:sqflite/sqflite.dart';

class CacheStore {
  CacheStore._();

  static final CacheStore instance = CacheStore._();

  static const String _dbName = 'guard_lab_cache.db';
  static const String _tableArticle = 'article_cache';

  Database? _db;

  // 懒初始化：首个访问者触发建库建表，之后的访问复用同一个连接
  Future<Database> get database async {
    final Database? existing = _db;
    if (existing != null && existing.isOpen) {
      return existing;
    }
    // getDatabasesPath 返回平台默认数据库目录，拼 DB 文件名即可
    final String dbPath = '${await getDatabasesPath()}/$_dbName';
    final Database db = await openDatabase(
      dbPath,
      // schema 版本只管库内建表结构演进，与任何依赖库版本无关
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE $_tableArticle('
          'id INTEGER PRIMARY KEY, '
          'title TEXT NOT NULL, '
          'summary TEXT NOT NULL, '
          'updated_at INTEGER NOT NULL)',
        );
      },
    );
    _db = db;
    return db;
  }

  // upsert：重复刷新同一条缓存时覆盖旧行，调用方不需要先查后插
  Future<void> putArticles(List<Map<String, Object?>> rows) async {
    final Database db = await database;
    final Batch batch = db.batch();
    for (final Map<String, Object?> row in rows) {
      batch.insert(
        _tableArticle,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, Object?>>> loadArticles() async {
    final Database db = await database;
    return db.query(_tableArticle, orderBy: 'updated_at DESC');
  }
}

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