// ============================================================
// 验证探针版（不入书）：清单 9-9 修复版全文 + 帧数据探针。
// 清单 9-9 为「局部替换」片段，本文件按其说明拼装成整文件：
//   - 新增 import 'dart:isolate'（清单 9-9 第 1 处改动）；
//   - onPressed 改 async + Isolate.run + mounted 防线（第 2 处改动）；
//   - pubspec environment sdk ^3.13.5（清单 9-9 注明，工程已满足）。
// 探针三处（PROBE 行）：addTimingsCallback 每帧打印 + COMPUTE 起止标记。
// 跑法：flutter run -d windows -t lib/main_probe_fixed.dart
// ============================================================
import 'dart:isolate'; // 新增导入，Isolate.run 在 dart:isolate 里（Dart 3 起）
import 'dart:ui' show FramePhase; // PROBE

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // PROBE

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // PROBE
  // PROBE: 每帧回执打印（读者自跑清单 9-9 看不到这些行）
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
        label: const Text('算 fib(35)（不卡了）'),
        onPressed: () async {
          setState(() => _status = '计算中…（现在去滚列表试试，应该顺滑如常）');
          print('COMPUTE_START atUs=${DateTime.now().microsecondsSinceEpoch}'); // PROBE
          // 修复：Isolate.run 起一个短命的 worker isolate，
          // fib(35) 在那边算，主 Isolate 继续排帧、响应手势。
          // await 挂起的只是这个回调，不是整个应用
          final int result = await Isolate.run(() => fib(35));
          print('COMPUTE_END atUs=${DateTime.now().microsecondsSinceEpoch}'); // PROBE
          // 计算的几秒里用户可能已经退出本页，
          // await 回来后同样要过 mounted 防线（正文 9.4 同款检查）
          if (!mounted) return;
          setState(() => _status = 'fib(35) = $result');
        },
      ),
    );
  }
}
