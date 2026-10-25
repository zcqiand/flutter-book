// lib/core/cart.dart
// 需求规格（16.1 同题共答的题面，四套实现逐字共用）：
// ①商品列表每项可加入购物车，重复加购数量+1；
// ②购物车逐项展示名称、单价、数量，数量可+1/-1，减到 0 即移除；
// ③底部结算行实时显示商品种类数与合计金额；
// ④支持一键清空。
// 模型层是不可变值对象：任何修改都返回新实例，四个方案比较的只是状态归谁、入口在哪
import 'package:flutter/foundation.dart';

/// 货架演示数据：四个版本共用同一份，保证对照时输入完全一致
const List<CartItem> kDemoShelf = <CartItem>[
  CartItem(name: '键盘', unitPrice: 199),
  CartItem(name: '鼠标', unitPrice: 89),
  CartItem(name: '显示器', unitPrice: 999),
];

@immutable
class CartItem {
  const CartItem({required this.name, required this.unitPrice, this.quantity = 1});
  final String name;
  final double unitPrice;
  final int quantity;

  CartItem increment() =>
      CartItem(name: name, unitPrice: unitPrice, quantity: quantity + 1);
  // 减到 0 即移除：返回 null，由上层把该项从列表删掉（规格②的收尾）
  CartItem? decrement() => quantity <= 1
      ? null
      : CartItem(name: name, unitPrice: unitPrice, quantity: quantity - 1);
}

@immutable
class CartState {
  const CartState({this.items = const <CartItem>[]});
  final List<CartItem> items;

  // 种类数与合计做派生 getter 而非存储字段：永远与 items 同步，规格③的
  // 实时性由数据结构本身保证，不存在「改了列表忘了算账」的缝隙
  int get kindCount => items.length;
  double get totalPrice =>
      items.fold(0.0, (double sum, CartItem item) => sum + item.unitPrice * item.quantity);
  // 规格①：同名项数量+1，否则作为新种类入车
  CartState addItem(CartItem newItem) {
    final List<CartItem> next = List<CartItem>.of(items);
    final int index = next.indexWhere((CartItem item) => item.name == newItem.name);
    if (index >= 0) {
      next[index] = next[index].increment();
    } else {
      next.add(newItem);
    }
    return CartState(items: next);
  }
  // 规格②：delta 只取 +1/-1，减到 0 的项就地移除
  CartState changeQuantity(String name, int delta) {
    final List<CartItem> next = List<CartItem>.of(items);
    final int index = next.indexWhere((CartItem item) => item.name == name);
    if (index < 0) return this;
    final CartItem? changed =
        delta > 0 ? next[index].increment() : next[index].decrement();
    if (changed == null) {
      next.removeAt(index);
    } else {
      next[index] = changed;
    }
    return CartState(items: next);
  }
  // 规格④：清空即回到空车
  CartState clearAll() => const CartState();
}