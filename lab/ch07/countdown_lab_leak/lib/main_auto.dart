// ============================================================
// 【验证 harness，非章内交付物】泄漏复现自动化入口。
// 背景：Windows 桌面非交互环境无法点击窗口，此 harness 用代码
// 精确复刻章内 7.5 的三步操作序列（进入倒计时页 → pop 返回首页
// → 盯控制台），State/Timer/心跳探针代码与清单 7-3 逐字一致，
// 仅额外给 debugPrint 套时间戳以便证据可判读。
// 清单原文 lib/main.dart 一字未动，flutter analyze 针对原文另行核验。
// ============================================================
import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  debugPrint = (String? message, {int? wrapWidth}) {
    // ignore: avoid_print
    print('[${DateTime.now().toIso8601String()}] $message');
  };
  // ignore: avoid_print
  print('[${DateTime.now().toIso8601String()}] AUTO: 应用启动，1.5 秒后自动进入倒计时页');
  runApp(const _AutoLeakApp());
}

class _AutoLeakApp extends StatelessWidget {
  const _AutoLeakApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _AutoDriver(),
    );
  }
}

/// 自动操作臂：挂载后 push 倒计时页，6 秒后 pop，随后继续运行 8 秒供观察
class _AutoDriver extends StatefulWidget {
  const _AutoDriver();

  @override
  State<_AutoDriver> createState() => _AutoDriverState();
}

class _AutoDriverState extends State<_AutoDriver> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ignore: avoid_print
      print('[${DateTime.now().toIso8601String()}] AUTO: 进入倒计时页（复刻「点进入倒计时页」）');
      Navigator.of(context)
          .push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const _LeakCountdownPage(),
            ),
          )
          .then((_) {
            // ignore: avoid_print
            print('[${DateTime.now().toIso8601String()}] AUTO: pop 返回首页（复刻「点返回退回首页」），开始盯控制台');
          });
      Timer(const Duration(seconds: 8), () {
        // ignore: avoid_print
        print('[${DateTime.now().toIso8601String()}] AUTO: 观察窗结束（pop 后已静置 6.5 秒）');
      });
    });
    Timer(const Duration(seconds: 6), () {
      // ignore: avoid_print
      print('[${DateTime.now().toIso8601String()}] AUTO: 按 pop（此时倒计时页应已显示约 6 秒）');
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('泄漏复现入口')),
      body: Center(child: Text('自动操作臂运行中，无需点击')),
    );
  }
}

// ——以下与清单 7-3 逐字一致（类名前加下划线避免与 main.dart 冲突）——

/// 入口页（清单 7-3 原文，此处不再被 harness 用到，保留以保持逐字对照）
class _LeakHomePage extends StatelessWidget {
  const _LeakHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('泄漏复现入口')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const _LeakCountdownPage(),
              ),
            );
          },
          child: const Text('进入倒计时页'),
        ),
      ),
    );
  }
}

class _LeakCountdownPage extends StatefulWidget {
  const _LeakCountdownPage();

  @override
  State<_LeakCountdownPage> createState() => _LeakCountdownPageState();
}

class _LeakCountdownPageState extends State<_LeakCountdownPage> {
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
