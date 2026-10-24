// lib/versions/riverpod_version.dart
// 需求规格见 lib/core/cart.dart 头注释（四条），本文件为方案 3 实现
// 边界：修改入口收敛于 CartNotifier 方法直改，与清单 15-3 的 FeedNotifier 同构；
// Riverpod Provider 分层组织依赖，状态不依赖 BuildContext 即可达
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/cart.dart';

/// 业务状态收敛入口：加购、改量、清空全是方法，页面只 watch 快照
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();
  void addItem(CartItem item) => state = state.addItem(item);
  void changeQuantity(String name, int delta) =>
      state = state.changeQuantity(name, delta);
  void clearAll() => state = state.clearAll();
}

final NotifierProvider<CartNotifier, CartState> cartNotifierProvider =
    NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

/// ConsumerWidget：watch 快照渲染，触发走 ref.read 拿 notifier
class RiverpodCartPage extends ConsumerWidget {
  const RiverpodCartPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CartState cart = ref.watch(cartNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod 版购物车')),
      body: ListView(
        children: <Widget>[
          for (final CartItem goods in kDemoShelf)
            ListTile(
              title: Text(goods.name),
              trailing: IconButton(icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () => ref.read(cartNotifierProvider.notifier).addItem(goods)),
            ),
          const Divider(),
          for (final CartItem item in cart.items)
            Row(children: <Widget>[
              Expanded(
                child: Text('${item.name} ${item.unitPrice.toStringAsFixed(0)} 元 ×${item.quantity}'),
              ),
              IconButton(onPressed: () => ref.read(cartNotifierProvider.notifier).changeQuantity(item.name, -1), icon: const Icon(Icons.remove_circle_outline)),
              IconButton(onPressed: () => ref.read(cartNotifierProvider.notifier).changeQuantity(item.name, 1), icon: const Icon(Icons.add_circle_outline)),
            ]),
          ListTile(
            title: Text('共 ${cart.kindCount} 种，合计 ${cart.totalPrice.toStringAsFixed(2)} 元'),
            trailing: TextButton(onPressed: cart.items.isEmpty ? null : () => ref.read(cartNotifierProvider.notifier).clearAll(), child: const Text('清空购物车')),
          ),
        ],
      ),
    );
  }
}
