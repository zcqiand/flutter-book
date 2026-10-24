// ============================================================
// 【验证 harness，非章内交付物】修复版自动化入口。
// 状态代码 = 清单 7-3 + 清单 7-5 两处修复（dispose cancel +
// mounted 守卫），另加两行 [FIX] 日志作 dispose 触发证据；
// debugPrint 套时间戳。自动操作序列与 main_auto.dart 完全相同。
// 清单原文 lib/main.dart 一字未动。
// ============================================================
import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  debugPrint = (String? message, {int? wrapWidth}) {
    // ignore: avoid_print
    print('[${DateTime.now().toIso8601String()}] $message');
  };
  // ignore: avoid_print
  print('[${DateTime.now().toIso8601String()}] AUTO(修复版): 应用启动，1.5 秒后自动进入倒计时页');
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
      print('[${DateTime.now().toIso8601String()}] AUTO(修复版): 进入倒计时页');
      Navigator.of(context)
          .push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const _FixedCountdownPage(),
            ),
          )
          .then((_) {
            // ignore: avoid_print
            print('[${DateTime.now().toIso8601String()}] AUTO(修复版): pop 返回首页，开始盯控制台');
          });
      Timer(const Duration(seconds: 8), () {
        // ignore: avoid_print
        print('[${DateTime.now().toIso8601String()}] AUTO(修复版): 观察窗结束（pop 后已静置 6.5 秒）');
      });
    });
    Timer(const Duration(seconds: 6), () {
      // ignore: avoid_print
      print('[${DateTime.now().toIso8601String()}] AUTO(修复版): 按 pop');
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

class _FixedCountdownPage extends StatefulWidget {
  const _FixedCountdownPage();

  @override
  State<_FixedCountdownPage> createState() => _FixedCountdownPageState();
}

class _FixedCountdownPageState extends State<_FixedCountdownPage> {
  Timer? _timer;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      // 清单 7-5 小改二：mounted 守卫，cancel 之外的第二道保险
      if (!mounted) {
        // ignore: avoid_print
        print('[${DateTime.now().toIso8601String()}] [FIX] mounted 守卫拦截已在路上的一跳，就地 cancel');
        timer.cancel();
        return;
      }
      debugPrint('泄漏心跳：剩余 $_remainingSeconds 秒');
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds -= 1);
      } else {
        timer.cancel();
      }
    });
  }

  // 清单 7-5 小改一：补回 dispose。[FIX] 行仅为 dispose 触发证据
  @override
  void dispose() {
    // ignore: avoid_print
    print('[${DateTime.now().toIso8601String()}] [FIX] dispose 触发：_timer?.cancel() 执行');
    _timer?.cancel();
    super.dispose();
  }

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
