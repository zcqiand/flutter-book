// ============================================================
// 教学正确版本：正文 9.2/9.4 FutureBuilder 三态页基准写法。
// 复现操作序列：
//   1. flutter run -d windows，启动后首页即本页；
//   2. 看加载态：约 2 秒加载圈；
//   3. 看数据态：列表浮现；
//   4. 拖动窗口缩放触发 rebuild，控制台不会闪回加载圈，
//      因为 future 存在 State 字段里，build 重跑不发新请求。
// 单文件自包含，零第三方依赖。
// ============================================================
import 'package:flutter/material.dart';

void main() {
  runApp(const AsyncLabApp());
}

class AsyncLabApp extends StatelessWidget {
  const AsyncLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrdersFuturePage(),
    );
  }
}

/// 模拟接口：2 秒后返回三笔订单。
/// 教学用 fake，真实项目里这里是 HTTP 调用，签名不变即可换芯。
Future<List<String>> fetchOrders() async {
  await Future<void>.delayed(const Duration(seconds: 2));
  return <String>['订单 1001 · 已发货', '订单 1002 · 待支付', '订单 1003 · 已完成'];
}

class OrdersFuturePage extends StatefulWidget {
  const OrdersFuturePage();

  @override
  State<OrdersFuturePage> createState() => _OrdersFuturePageState();
}

class _OrdersFuturePageState extends State<OrdersFuturePage> {
  // 正文 9.4：future 存进 State 字段，initState 里只发一次请求。
  // 为什么不放 build：build 会被框架反复调用（窗口缩放、键盘弹出都算），
  // future 写在 build 的参数位置等于每次重建都重新发一次请求，
  // 加载圈反复闪回，这是 FutureBuilder 最常见的误用
  late final Future<List<String>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('订单列表 · FutureBuilder 版')),
      body: FutureBuilder<List<String>>(
        future: _ordersFuture,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          // 三态之一：等待态，给加载圈
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 三态之二：错误态，Future 完成但带着异常，给提示页而不是崩溃
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }
          // 三态之三：数据态，正常渲染
          final List<String> orders = snapshot.data ?? const <String>[];
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (BuildContext context, int index) => ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(orders[index]),
            ),
          );
        },
      ),
    );
  }
}