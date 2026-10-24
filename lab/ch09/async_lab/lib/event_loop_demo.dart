// ============================================================
// 教学演示版本（非失败版）：正文 9.1 事件循环排程实验。
// 复现操作序列：
//   1. 在 async_lab 目录执行 dart run lib/event_loop_demo.dart；
//   2. 先自己猜打印顺序，再对照实际输出（见本清单配套回执）。
// 看什么：七行打印的出场顺序，同步、微任务、事件任务三类各排第几。
// 纯 Dart 单文件，零第三方依赖，不需要 Flutter。
// ============================================================
import 'dart:async';

void main() {
  // 第 1 行：同步代码最先跑完。事件循环此刻还没登场，
  // 它只负责在 main 返回之后接手队列里的活
  print('1 同步: main 开始');

  // 第 3 行：scheduleMicrotask 进微任务队列。
  // main 一结束，事件循环先清空整个微任务队列，才考虑事件队列
  scheduleMicrotask(() {
    print('3 微任务: scheduleMicrotask');
  });

  // 第 5 行：Future(fn) 的回调进事件任务队列，按入队先后出队
  Future(() {
    print('5 事件任务: Future 直接排程');
  });

  // 第 7 行：Future.delayed 不进队列，先挂一个定时器，
  // 时间到点才把回调放进事件任务队列，所以排在两个直接排程的后面
  Future.delayed(const Duration(milliseconds: 50), () {
    print('7 事件任务: Future.delayed 50 毫秒');
  });

  // 第 6 行：第二个事件任务，排在第 5 行后面，队列先来先服务
  Future(() {
    print('6 事件任务: 第二个 Future');
  });

  // 第 4 行：第二个微任务。微任务队列是「全清完才换队」，
  // 不是「清一个就回头查一次事件队列」，所以 3 和 4 连续出场
  scheduleMicrotask(() {
    print('4 微任务: 第二个 scheduleMicrotask');
  });

  // 第 2 行：同步代码继续往下走，此刻所有异步回调都还在排队
  print('2 同步: main 结束');
}
