// test/cart_riverpod_test.dart — 清单16-5 Riverpod 版四组断言
import 'package:cart_lab/versions/riverpod_version.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  testWidgets('Riverpod 版：七步脚本全 PASS（加购/重复+1/减到0移除/结算行/清空）',
      (WidgetTester tester) async {
    await runCartScript(
        tester, 'riverpod', const ProviderScope(child: RiverpodCartPage()));
  });
}
