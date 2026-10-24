// ============================================================
// 教学故意失败版本：本工程就是用来跑出滚动掉帧的。
// 复现操作序列（正文 9.5）：
//   1. flutter run -d windows；
//   2. 先正常滚动列表，记住顺滑的手感；
//   3. 点右下角「算 fib(35)」，在状态栏变为「计算中」的几秒里
//      继续滚动列表：列表一顿一顿，肉眼可见的卡顿；
//   4. 按清单 9-10 的口径记下帧数据，与清单 9-9 修复版对比。
// 单文件自包含，零第三方依赖。
// ============================================================
import 'package:flutter/material.dart';

void main() {
  runApp(const IsolateLabApp());
}

class IsolateLabApp extends StatelessWidget {
  const IsolateLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: JankPage(),
    );
  }
}

/// 朴素的递归 Fibonacci：O(2^n) 的 CPU 密集计算。
/// 选它而不是大循环哈希，是因为调用树深达数亿层、全程吃满 CPU，
/// 且 n 是个位数字面量，教学时改动门槛最低
int fib(int n) => n <= 1 ? n : fib(n - 1) + fib(n - 2);

class JankPage extends StatefulWidget {
  const JankPage();

  @override
  State<JankPage> createState() => _JankPageState();
}

class _JankPageState extends State<JankPage> {
  String _status = '先顺滑地滚一滚列表，再点右下角按钮';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Isolate 诊所 · 卡顿病房')),
      body: Column(
        children: <Widget>[
          Padding(padding: const EdgeInsets.all(8), child: Text(_status)),
          Expanded(
            child: ListView.builder(
              itemCount: 500,
              itemBuilder: (BuildContext context, int index) => ListTile(
                leading: CircleAvatar(child: Text('$index')),
                title: Text('条目 $index'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('算 fib(35)'),
        onPressed: () {
          setState(() => _status = '计算中…（现在去滚列表试试）');
          // 病灶：同步重计算直接跑在主 Isolate 上。
          // 主 Isolate 是唯一能执行 build、布局、绘制、手势的执行流，
          // 它被 fib(35) 独占的这几秒里，事件队列上的帧任务全都排不上队，
          // 500 条的列表此刻滚不出第二帧
          final int result = fib(35);
          setState(() => _status = 'fib(35) = $result');
        },
      ),
    );
  }
}
