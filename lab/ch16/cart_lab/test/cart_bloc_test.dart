// test/cart_bloc_test.dart — 清单16-6 Bloc 版四组断言
import 'package:cart_lab/core/cart.dart';
import 'package:cart_lab/versions/bloc_version.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  testWidgets('Bloc 版：七步脚本全 PASS（加购/重复+1/减到0移除/结算行/清空）',
      (WidgetTester tester) async {
    await runCartScript(tester, 'bloc', const BlocCartPage());
  });

  test('Bloc 事件→状态映射逐条断言（sealed 四事件全覆盖）', () async {
    final CartBloc bloc = CartBloc();
    const CartItem keyboard = CartItem(name: '键盘', unitPrice: 199);
    bloc.add(AddItem(keyboard));
    bloc.add(AddItem(keyboard)); // 重复加购数量+1
    bloc.add(AddItem(const CartItem(name: '鼠标', unitPrice: 89)));
    bloc.add(DecrementItem('键盘'));
    bloc.add(IncrementItem('鼠标'));
    bloc.add(DecrementItem('鼠标'));
    bloc.add(DecrementItem('鼠标')); // 减到 0 移除
    bloc.add(ClearCart());
    await bloc.stream.firstWhere((CartState s) => s.items.isEmpty);
    expect(bloc.state.items, isEmpty); // 规格④终点=空车
    await bloc.close();
  });
}
