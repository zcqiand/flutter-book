// test/token_store_test.dart
// 清单 17-8 token 段测试：存取删三动作全链。
// flutter_secure_storage 用官方内存测试平台（flutter_secure_storage 11.2.0 自带
// TestFlutterSecureStoragePlatform），回执落盘 test/receipts/17_9_token.txt。
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guard_lab/storage/token_store.dart';

import 'receipt.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('token 层：存取删三动作（清单17-9 token 段）', () async {
    final Map<String, String> backing = <String, String>{};
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(backing);
    final TokenStore store = const TokenStore();
    const String demoToken = 'demo-token-0123456789abcdef';
    final List<String> lines = <String>['RECEIPT_BEGIN|17_9_token'];

    // step1 未写入时读为空：空值即未登录态，本身就是有效答案
    final String? initial = await store.read();
    lines.add('STEP|step1-未写先读|actual=${initial ?? 'null'}|expected=null|${initial == null ? 'PASS' : 'FAIL'}');

    // step2 写入后读出一致
    await store.write(demoToken);
    final String? stored = await store.read();
    lines.add('STEP|step2-写后读|actual=$stored|expected=$demoToken|${stored == demoToken ? 'PASS' : 'FAIL'}');

    // step3 覆盖写新值
    await store.write('demo-token-renewed');
    final String? renewed = await store.read();
    lines.add('STEP|step3-覆盖写|actual=$renewed|expected=demo-token-renewed|${renewed == 'demo-token-renewed' ? 'PASS' : 'FAIL'}');

    // step4 删除后读必须为空：删干净，登录态才算收回
    await store.delete();
    final String? afterDelete = await store.read();
    lines.add('STEP|step4-删后读|actual=${afterDelete ?? 'null'}|expected=null|${afterDelete == null ? 'PASS' : 'FAIL'}');
    lines.add('STEP|step4-删后读-底层干净|actual=${backing.isEmpty ? '空' : '残留${backing.length}键'}|expected=空|${backing.isEmpty ? 'PASS' : 'FAIL'}');

    lines.add('RECEIPT_END|17_9_token');
    for (final String line in lines.where((String l) => l.startsWith('STEP|'))) {
      expect(line.endsWith('|PASS'), isTrue, reason: line);
    }
    await writeReceiptPlain('17_9_token.txt', lines);
  });
}
