// lib/versions/setstate_version.dart
// 需求规格见 lib/core/cart.dart 头注释（四条），本文件为方案 1 实现
// 边界：CartState 是单个 StatefulWidget 的组件私有 UI 状态（ch4 口径），
// 修改与展示在同一个 State 里自洽；状态一出本组件就得另寻方案，
// setState 没有任何跨组件接力机制
import 'package:flutter/material.dart';
import '../core/cart.dart';

class SetStateCartPage extends StatefulWidget {
  const SetStateCartPage({super.key});
  @override
  State<SetStateCartPage> createState() => _SetStateCartPageState();
}

class _SetStateCartPageState extends State<SetStateCartPage> {
  CartState _cart = const CartState();
  // 唯一修改缝：任何操作都换成新 CartState 再交给 setState 触发重建
  void _update(CartState next) => setState(() => _cart = next);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('setState 版购物车')),
      body: ListView(
        children: <Widget>[
          for (final CartItem goods in kDemoShelf)
            ListTile(
              title: Text(goods.name),
              trailing: IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                // 重复加购即同名项数量+1：算账在共享模型里，这里只触发重建
                onPressed: () => _update(_cart.addItem(goods)),
              ),
            ),
          const Divider(),
          for (final CartItem item in _cart.items)
            Row(children: <Widget>[
              Expanded(
                child: Text('${item.name} ${item.unitPrice.toStringAsFixed(0)} 元 ×${item.quantity}'),
              ),
              IconButton(
                onPressed: () => _update(_cart.changeQuantity(item.name, -1)),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              IconButton(
                onPressed: () => _update(_cart.changeQuantity(item.name, 1)),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ]),
          ListTile(
            // 结算行直接读派生 getter，重建即自动最新（规格③）
            title: Text('共 ${_cart.kindCount} 种，合计 ${_cart.totalPrice.toStringAsFixed(2)} 元'),
            trailing: TextButton(
              onPressed:
                  _cart.items.isEmpty ? null : () => _update(_cart.clearAll()),
              child: const Text('清空购物车'),
            ),
          ),
        ],
      ),
    );
  }
}