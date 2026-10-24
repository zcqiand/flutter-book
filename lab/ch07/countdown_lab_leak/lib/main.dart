// ============================================================
// 教学故意失败版本：与清单 7-1 同一款倒计时，只动两处。
//   1. dispose 整个缺席（对账窗口没了）；
//   2. 回调里加 debugPrint，让 Timer 的心跳在控制台可见。
// 它是故意写错的：先按正文 7.5 的操作序列跑一遍，
// 看页面退场后控制台还在不在跳秒，再对照清单 7-5 修复。
// ============================================================
import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const CountdownLeakApp());
}

class CountdownLeakApp extends StatelessWidget {
  const CountdownLeakApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LeakHomePage(),
    );
  }
}

/// 入口页只负责一件事：把倒计时页推进路由栈，
/// 这样「退出页面」才有观察点，退回首页后控制台还响不响，一眼可辨
class LeakHomePage extends StatelessWidget {
  const LeakHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('泄漏复现入口')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const LeakCountdownPage(),
              ),
            );
          },
          child: const Text('进入倒计时页'),
        ),
      ),
    );
  }
}

class LeakCountdownPage extends StatefulWidget {
  const LeakCountdownPage();

  @override
  State<LeakCountdownPage> createState() => _LeakCountdownPageState();
}

class _LeakCountdownPageState extends State<LeakCountdownPage> {
  Timer? _timer;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      // 心跳打印是教学探针：页面退场后它在不在跳，控制台一翻便知；
      // 清单 7-4 抓的正是退场后仍然每秒出现的这些行
      debugPrint('泄漏心跳：剩余 $_remainingSeconds 秒');
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds -= 1);
      } else {
        timer.cancel();
      }
    });
  }

  // 教学改动全在这一处缺席：dispose 没写。
  // 没人 cancel，Timer 就带着回调与 State 活在页面之外（正文 7.5 归因段）

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('倒计时（退出本页后盯控制台）')),
      body: Center(
        child: Text(
          '$_remainingSeconds',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}
