// lib/versions/inherited_version.dart
// 需求规格见 lib/core/cart.dart 头注释（四条），本文件为方案 2 实现
// 边界（回收 15.1）：机制只管只读下发与依赖登记，谁改、怎么改机制不问，修改入口只能塞回顶层容器——15.1 说的机制空白
import 'package:flutter/material.dart';
import '../core/cart.dart';

/// 机制组件：只读下发层，自身不持状态、不提供任何修改入口
class CartScope extends InheritedWidget {
  const CartScope({super.key, required this.cart, required super.child});
  final CartState cart;

  // 依赖查找同时完成依赖登记：经此取值的组件在 cart 换新实例时自动重建
  static CartState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CartScope>()!.cart;
  @override
  bool updateShouldNotify(CartScope oldWidget) => oldWidget.cart != cart;
}

/// 容器：状态唯一持有者，四个修改入口全经 setState 落在这里
class CartContainer extends StatefulWidget {
  const CartContainer({super.key, required this.child});
  final Widget child;
  @override
  State<CartContainer> createState() => _CartContainerState();
}

class _CartContainerState extends State<CartContainer> {
  CartState _cart = const CartState();
  void addItem(CartItem item) => setState(() => _cart = _cart.addItem(item));
  void changeQuantity(String name, int delta) =>
      setState(() => _cart = _cart.changeQuantity(name, delta));
  void clearAll() => setState(() => _cart = _cart.clearAll());
  @override
  Widget build(BuildContext context) => CartScope(cart: _cart, child: widget.child);
}

/// 页面：读走 CartScope.of(context)；机制不提供上行通道，改只能翻找
/// 容器 State 本体握手，这是方案 2 真实的使用成本
class InheritedCartPage extends StatelessWidget {
  const InheritedCartPage({super.key});
  static _CartContainerState _container(BuildContext context) =>
      context.findAncestorStateOfType<_CartContainerState>()!;
  @override
  Widget build(BuildContext context) {
    final CartState cart = CartScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('InheritedWidget 版购物车')),
      body: ListView(
        children: <Widget>[
          for (final CartItem goods in kDemoShelf)
            ListTile(
              title: Text(goods.name),
              trailing: IconButton(icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () => _container(context).addItem(goods)),
            ),
          const Divider(),
          for (final CartItem item in cart.items)
            Row(children: <Widget>[
              Expanded(
                child: Text('${item.name} ${item.unitPrice.toStringAsFixed(0)} 元 ×${item.quantity}'),
              ),
              IconButton(onPressed: () => _container(context).changeQuantity(item.name, -1), icon: const Icon(Icons.remove_circle_outline)),
              IconButton(onPressed: () => _container(context).changeQuantity(item.name, 1), icon: const Icon(Icons.add_circle_outline)),
            ]),
          ListTile(
            title: Text('共 ${cart.kindCount} 种，合计 ${cart.totalPrice.toStringAsFixed(2)} 元'),
            trailing: TextButton(onPressed: cart.items.isEmpty ? null : () => _container(context).clearAll(), child: const Text('清空购物车')),
          ),
        ],
      ),
    );
  }
}