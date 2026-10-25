// 修复版本（正文 9.5）：与清单 9-8 相同工程，只改两处。
// 复现操作序列不变：点按钮、计算期间滚列表。
// 预期现象：数字出来得并不更快（计算耗时不变，约 0.8 秒），但列表全程顺滑如常
import 'dart:isolate'; // 新增导入，Isolate.run 在 dart:isolate 里（Dart 2.19 引入、Dart 3 起稳定可用）

floatingActionButton: FloatingActionButton.extended(
  label: const Text('算 fib(40)（不卡了）'),
  onPressed: () async {
    setState(() => _status = '计算中…（现在去滚列表试试，应该顺滑如常）');
    // 修复：Isolate.run 起一个短命的 worker isolate，
    // fib(40) 在那边算，主 Isolate 继续排帧、响应手势。
    // await 挂起的只是这个回调，不是整个应用
    final int result = await Isolate.run(() => fib(40));
    // 计算期间用户可能已经退出本页，
    // await 回来后同样要过 mounted 防线（正文 9.4 同款检查）
    if (!mounted) return;
    setState(() => _status = 'fib(40) = $result');
  },
)

// 入参与返回值都走拷贝（正文 9.5 内存隔离）：isolate 之间没有共享内存，
// 闭包捕获的 40、算出来的 result，都是跨 isolate 拷贝过去的两份独立对象。
// 所以 Isolate.run 有通信成本，只值得用在「计算耗时远超拷贝耗时」的场景：
// fib(40) 这种近一秒的计算稳赚；给几百个元素排个序这种毫秒级活，
// 拷贝与起停的成本比计算本身还贵，留在主 Isolate 反而更快（正文 9.5 反例）

// isolate_lab/pubspec.yaml 的环境约束只需一行（Isolate.run 需 Dart 2.19 及以上）：
// environment:
//   sdk: ^3.13.5