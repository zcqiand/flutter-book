// test/cart_inherited_test.dart — 清单16-4 InheritedWidget 版四组断言
import 'package:cart_lab/versions/inherited_version.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  testWidgets('InheritedWidget 版：七步脚本全 PASS（加购/重复+1/减到0移除/结算行/清空）',
      (WidgetTester tester) async {
    await runCartScript(
        tester, 'inherited', const CartContainer(child: InheritedCartPage()));
  });
}
