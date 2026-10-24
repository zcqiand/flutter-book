// test/cart_setstate_test.dart — 清单16-3 setState 版四组断言
import 'package:cart_lab/versions/setstate_version.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  testWidgets('setState 版：七步脚本全 PASS（加购/重复+1/减到0移除/结算行/清空）',
      (WidgetTester tester) async {
    await runCartScript(tester, 'setstate', const SetStateCartPage());
  });
}
