// test/settings_store_test.dart
// 清单 17-7 设置层测试：写读删全链 + 幂等默认值；回执落盘 test/receipts/17_9_settings.txt。
// shared_preferences 用官方 mock 存储通道（SharedPreferences.setMockInitialValues）。
import 'package:flutter_test/flutter_test.dart';
import 'package:guard_lab/storage/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'receipt.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('设置层：幂等默认值 + 写读删三段（清单17-9 settings 段）', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SettingsStore store = SettingsStore();
    final List<String> lines = <String>['RECEIPT_BEGIN|17_9_settings'];

    // step1 幂等默认值：从未写过时读出与首次安装一致的默认值
    final int defaultMode = await store.loadThemeMode();
    final bool defaultNotice = await store.loadNoticeEnabled();
    final bool ok1 = defaultMode == 0 && defaultNotice == true;
    lines.add('STEP|step1-未写过读默认|actual=theme_mode=$defaultMode,notice=$defaultNotice|expected=theme_mode=0,notice=true|${ok1 ? 'PASS' : 'FAIL'}');

    // step2 写主题模式 1 后读出 1
    await store.saveThemeMode(1);
    final int mode = await store.loadThemeMode();
    lines.add('STEP|step2-写theme_mode=1再读|actual=$mode|expected=1|${mode == 1 ? 'PASS' : 'FAIL'}');

    // step3 写通知开关 false 后读出 false
    await store.saveNoticeEnabled(false);
    final bool notice = await store.loadNoticeEnabled();
    lines.add('STEP|step3-写notice=false再读|actual=$notice|expected=false|${notice == false ? 'PASS' : 'FAIL'}');

    // step4 删除键后再读：回幂等默认值（0 / true）
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('guard_lab.settings.theme_mode');
    await prefs.remove('guard_lab.settings.notice_enabled');
    final int modeAfterDelete = await store.loadThemeMode();
    final bool noticeAfterDelete = await store.loadNoticeEnabled();
    final bool ok4 = modeAfterDelete == 0 && noticeAfterDelete == true;
    lines.add('STEP|step4-删键后读回默认|actual=theme_mode=$modeAfterDelete,notice=$noticeAfterDelete|expected=theme_mode=0,notice=true|${ok4 ? 'PASS' : 'FAIL'}');

    lines.add('RECEIPT_END|17_9_settings');
    for (final String line in lines.where((String l) => l.startsWith('STEP|'))) {
      expect(line.endsWith('|PASS'), isTrue, reason: line);
    }
    await writeReceiptPlain('17_9_settings.txt', lines);
  });
}
