// lib/versions/bloc_version.dart
// 需求规格见 lib/core/cart.dart 头注释（四条），本文件为方案 4 实现
// 边界（对照项非主线）：事件进、状态出、中间显式映射，修改意图先造成事件对象再由映射表翻译成新状态，与 Riverpod 的方法直改互为范式对照
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/cart.dart';

/// 事件即意图：sealed 保证映射漏掉某种事件时编译期直接报警
sealed class CartEvent {
  const CartEvent();
}
class AddItem extends CartEvent {
  const AddItem(this.item);
  final CartItem item;
}
class IncrementItem extends CartEvent {
  const IncrementItem(this.name);
  final String name;
}
class DecrementItem extends CartEvent {
  const DecrementItem(this.name);
  final String name;
}
class ClearCart extends CartEvent {
  const ClearCart();
}

/// 显式映射：每种事件一行 on<...>，四条修改路径一目了然
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddItem>((AddItem e, Emitter<CartState> emit) => emit(state.addItem(e.item)));
    on<IncrementItem>((IncrementItem e, Emitter<CartState> emit) => emit(state.changeQuantity(e.name, 1)));
    on<DecrementItem>((DecrementItem e, Emitter<CartState> emit) => emit(state.changeQuantity(e.name, -1)));
    on<ClearCart>((ClearCart e, Emitter<CartState> emit) => emit(state.clearAll()));
  }
}

/// 页面：BlocProvider 注入，读走 context.watch，改走 read().add() 派事件
class BlocCartPage extends StatelessWidget {
  const BlocCartPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CartBloc>(
      create: (BuildContext context) => CartBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Bloc 版购物车')),
        body: Builder(builder: (BuildContext context) {
          final CartState cart = context.watch<CartBloc>().state;
          return ListView(
            children: <Widget>[
              for (final CartItem goods in kDemoShelf)
                ListTile(
                  title: Text(goods.name),
                  trailing: IconButton(icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => context.read<CartBloc>().add(AddItem(goods))),
                ),
              const Divider(),
              for (final CartItem item in cart.items)
                Row(children: <Widget>[
                  Expanded(
                    child: Text('${item.name} ${item.unitPrice.toStringAsFixed(0)} 元 ×${item.quantity}'),
                  ),
                  IconButton(onPressed: () => context.read<CartBloc>().add(IncrementItem(item.name)), icon: const Icon(Icons.add_circle_outline)),
                  IconButton(onPressed: () => context.read<CartBloc>().add(DecrementItem(item.name)), icon: const Icon(Icons.remove_circle_outline)),
                ]),
              ListTile(
                title: Text('共 ${cart.kindCount} 种，合计 ${cart.totalPrice.toStringAsFixed(2)} 元'),
                trailing: TextButton(onPressed: cart.items.isEmpty ? null : () => context.read<CartBloc>().add(ClearCart()), child: const Text('清空购物车')),
              ),
            ],
          );
        }),
      ),
    );
  }
}