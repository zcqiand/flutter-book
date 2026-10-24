// ============================================================
// 教学正确版本：正文 9.3 Stream 订阅生命周期 + 9.4 StreamBuilder 三态。
// 复现操作序列：
//   1. flutter run -d windows；
//   2. 看两路数据：顶部徽标每秒 +1（手动订阅的计时流），
//      列表每 1.5 秒多露出一笔订单（StreamBuilder 消费的单订阅流）；
//   3. 按返回键退出页面，控制台安静，因为订阅在 dispose 里被取消。
// 单文件自包含，零第三方依赖。
// ============================================================
import 'dart:async';

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
      home: OrdersStreamPage(),
    );
  }
}

class OrdersStreamPage extends StatefulWidget {
  const OrdersStreamPage();

  @override
  State<OrdersStreamPage> createState() => _OrdersStreamPageState();
}

class _OrdersStreamPageState extends State<OrdersStreamPage> {
  // 正文 9.3 / 7.3：手动 listen 出来的订阅要攥在字段里，
  // dispose 时 cancel，这是订阅清理纪律的完整闭环。
  // StreamBuilder 不需要这一步，因为它在组件移除时会自动退订
  StreamSubscription<int>? _tickerSub;
  int _elapsedSeconds = 0;

  /// 单订阅流模拟数据序列（正文 9.3）：每 1.5 秒推一批更完整的订单，
  /// 推三轮后流自然关闭。async* 函数体里 yield 一次，流就多一个数据事件
  Stream<List<String>> orderStatusStream() async* {
    const List<String> all = <String>[
      '订单 1001 · 已发货',
      '订单 1002 · 待支付',
      '订单 1003 · 已完成',
    ];
    for (int i = 1; i <= all.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      yield all.sublist(0, i);
    }
  }

  @override
  void initState() {
    super.initState();
    _tickerSub = Stream<int>.periodic(
      const Duration(seconds: 1),
      (int tick) => tick,
    ).listen((int tick) {
      // 手动订阅的回调同样要过 mounted 防线（正文 9.4 同款检查）：
      // 页面销毁后定时流还会再推数据，不能对已卸载的 State 调 setState
      if (!mounted) return;
      setState(() => _elapsedSeconds = tick + 1);
    });
  }

  @override
  void dispose() {
    // 正文 9.3 / 7.3：谁订阅谁取消，dispose 是最后期限。
    // 漏掉这行的后果见正文 9.4 的竞态现场
    _tickerSub?.cancel();
    _tickerSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('订单列表 · StreamBuilder 版')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('已等待 $_elapsedSeconds 秒'),
          ),
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: orderStatusStream(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                // 等待态：流还没推来第一批数据
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 数据态：拿最近一次 yield 的批次渲染。
                // 流没有 hasError 之外的分支时，错误态写法与清单 9-4 相同
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
          ),
        ],
      ),
    );
  }
}
