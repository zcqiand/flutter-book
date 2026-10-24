// ============================================================
// 验证环境探针（不入书）：11.4 反例对照 harness——清单 11-5 删掉 dispose
// 的泄漏版（按 7.5 体例）。结构复刻清单 11-5：LifecyclePage 结构不变，
// 改动仅两处：① forward() 换 repeat()（持续动画才有「进度值还在动」）；
// ② 删 dispose 整段；另挂 500ms Timer 打印控制器当前进度作心跳。
// 自动驱动：进页 1s 后自动 push，3.5s 后自动 pop，观察至 9s。
// ============================================================
import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const LeakLabApp());
}

void _log(String msg) {
  final DateTime now = DateTime.now();
  // ignore: avoid_print
  print('[${now.toIso8601String()}] $msg');
}

class LeakLabApp extends StatelessWidget {
  const LeakLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LeakEntryPage(),
    );
  }
}

class LeakEntryPage extends StatefulWidget {
  const LeakEntryPage({super.key});

  @override
  State<LeakEntryPage> createState() => _LeakEntryPageState();
}

class _LeakEntryPageState extends State<LeakEntryPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1000), () {
      _log('[auto] push LeakLifecyclePage（含 repeat 控制器、无 dispose）');
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const LeakLifecyclePage(),
      ));
    });
    Timer(const Duration(milliseconds: 3500), () {
      _log('[auto] pop 泄漏页 ←— 此后若进度仍变化即泄漏坐实');
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('入口页')),
      body: const Center(child: Text('1 秒后自动进入泄漏页')),
    );
  }
}

class LeakLifecyclePage extends StatefulWidget {
  const LeakLifecyclePage({super.key});

  @override
  State<LeakLifecyclePage> createState() => _LeakLifecyclePageState();
}

class _LeakLifecyclePageState extends State<LeakLifecyclePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // ignore: unused_field
  Timer? _heart; // 反例版无人 cancel，字段保留本身即泄漏叙事的一部分

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.repeat(); // 反例版：循环播放，便于观察「退页后仍在动」
    _heart = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      _log('泄漏心跳：控制器进度=${_controller.value.toStringAsFixed(3)}');
    });
  }

  // 反例：清单 11-5 的 dispose 整段在此被删除（复现泄漏，勿仿）

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('控制器的建与还（泄漏反例）')),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Transform.scale(
              scale: 0.5 + _controller.value * 1.0,
              child: const FlutterLogo(size: 80),
            );
          },
        ),
      ),
    );
  }
}
