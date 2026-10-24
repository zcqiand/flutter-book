// ============================================================
// 验证环境探针（不入书）：11.4 修复版对照 harness——清单 11-5 原样结构
// （dispose 成对保留）+ repeat 档 + 同款 500ms 心跳，与泄漏版逐项对照。
// 自动驱动时序与泄漏版完全一致（1s push / 3.5s pop / 观察至 9s）。
// ============================================================
import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const FixedLabApp());
}

void _log(String msg) {
  final DateTime now = DateTime.now();
  // ignore: avoid_print
  print('[${now.toIso8601String()}] $msg');
}

class FixedLabApp extends StatelessWidget {
  const FixedLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FixedEntryPage(),
    );
  }
}

class FixedEntryPage extends StatefulWidget {
  const FixedEntryPage({super.key});

  @override
  State<FixedEntryPage> createState() => _FixedEntryPageState();
}

class _FixedEntryPageState extends State<FixedEntryPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1000), () {
      _log('[auto] push FixedLifecyclePage（repeat 控制器 + dispose 成对）');
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const FixedLifecyclePage(),
      ));
    });
    Timer(const Duration(milliseconds: 3500), () {
      _log('[auto] pop 修复页 ←— dispose 应在此前后触发，心跳随后冻结');
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('入口页')),
      body: const Center(child: Text('1 秒后自动进入修复页')),
    );
  }
}

class FixedLifecyclePage extends StatefulWidget {
  const FixedLifecyclePage({super.key});

  @override
  State<FixedLifecyclePage> createState() => _FixedLifecyclePageState();
}

class _FixedLifecyclePageState extends State<FixedLifecyclePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _heart;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.repeat();
    _heart = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      _log('心跳：控制器进度=${_controller.value.toStringAsFixed(3)}');
    });
  }

  @override
  void dispose() {
    // 成对纪律（清单 11-5 原样）：先停心跳探针，再还控制器
    _heart?.cancel();
    _log('[FIX] dispose 触发：_heart.cancel() + _controller.dispose() 执行');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('控制器的建与还（修复对照）')),
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
