// test/cart_model_test.dart — 清单16-2 共享规格与不可变模型直测（规格①②③④逐条对）
import 'package:cart_lab/core/cart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('规格①：加购入车，重复加购数量+1', () {
    CartState cart = const CartState().addItem(kDemoShelf[0]);
    expect(cart.kindCount, 1);
    cart = cart.addItem(kDemoShelf[0]);
    expect(cart.items.single.quantity, 2);
    expect(cart.items.single.name, '键盘');
  });

  test('规格②：+1/-1 可改量，减到 0 即移除', () {
    CartState cart = const CartState().addItem(kDemoShelf[0]);
    cart = cart.changeQuantity('键盘', 1);
    expect(cart.items.single.quantity, 2);
    cart = cart.changeQuantity('键盘', -1);
    expect(cart.items.single.quantity, 1);
    cart = cart.changeQuantity('键盘', -1);
    expect(cart.items, isEmpty); // 减到 0 移除，回空车
  });

  test('规格③：种类数与合计是派生 getter，实时跟随 items', () {
    CartState cart = const CartState()
        .addItem(kDemoShelf[0])
        .addItem(kDemoShelf[1])
        .addItem(kDemoShelf[0]);
    expect(cart.kindCount, 2);
    expect(cart.totalPrice, 199 * 2 + 89);
    expect(cart.items.length, 2); // 派生值不落存储字段
  });

  test('规格④：一键清空回空车', () {
    final CartState cart = const CartState()
        .addItem(kDemoShelf[0])
        .addItem(kDemoShelf[2])
        .clearAll();
    expect(cart.items, isEmpty);
    expect(cart.kindCount, 0);
    expect(cart.totalPrice, 0.0);
  });

  test('不可变性：任何修改返回新实例，原实例不动', () {
    const CartState before = CartState();
    final CartState after = before.addItem(kDemoShelf[0]);
    expect(identical(before, after), isFalse);
    expect(before.items, isEmpty);
  });
}
