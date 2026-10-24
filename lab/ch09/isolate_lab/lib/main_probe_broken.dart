// ============================================================
// 验证探针版（不入书）：清单 9-8 全文 + 帧数据探针。
// 探针三处（均在标注 PROBE 的行）：
//   1. main 里 SchedulerBinding.addTimingsCallback 每帧打印 totalSpan；
//   2. onPressed 里 COMPUTE_START / COMPUTE_END 边界标记。
// 其余与清单 9-8 逐字一致。
// 跑法：flutter run -d windows -t lib/main_probe_broken.dart
// ============================================================
import 'dart:ui' show FramePhase; // PROBE

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // PROBE

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // PROBE
  // PROBE: 每帧回执打印（读者自跑清单 9-8 看不到这些行）
  SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
    for (final FrameTiming t in timings) {
      print('FRAMETIMING vsyncUs=${t.timestampInMicroseconds(FramePhase.vsyncStart)} '
          'totalSpanMs=${t.totalSpan.inMicroseconds / 1000.0}');
    }
  });
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
          print('COMPUTE_START atUs=${DateTime.now().microsecondsSinceEpoch}'); // PROBE
          final int result = fib(35);
          print('COMPUTE_END atUs=${DateTime.now().microsecondsSinceEpoch}'); // PROBE
          setState(() => _status = 'fib(35) = $result');
        },
      ),
    );
  }
}
