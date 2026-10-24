// lib/storage/settings_store.dart
// KV 设置层：异步读写、幂等默认值（键不存在时返回与首次安装一致的默认值，
// 读代码的人不需要关心「这个键写过没有」）
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  // 键名集中声明：拼写错误在编译期暴露，而不是在运行期悄悄读出 null
  static const String _kThemeMode = 'guard_lab.settings.theme_mode';
  static const String _kNoticeEnabled = 'guard_lab.settings.notice_enabled';

  Future<int> loadThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kThemeMode) ?? 0; // 0 即跟随系统，从未写过时同样返回它
  }

  Future<void> saveThemeMode(int mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeMode, mode);
  }

  Future<bool> loadNoticeEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNoticeEnabled) ?? true; // 默认开
  }

  Future<void> saveNoticeEnabled(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNoticeEnabled, value);
  }
}
