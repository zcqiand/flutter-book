// lib/demo/exception_lab.dart
// 三个触发函数各代表一层异常，页面上三个按钮一一对应，配清单 17-2 的日志回执对照看
import 'package:flutter/material.dart';

/// 第一层「同步」：同步代码里的异常，try-catch 就地捕获，
/// 这一层由最近的 catch 接，轮不到任何全局缝位出手
void triggerSyncException() {
  try {
    throw const FormatException('同步层：故意抛出的格式异常');
  } on FormatException catch (error) {
    debugPrint('[guard_lab][sync-catch] 就地捕获：$error');
  }
}

/// 第二层「异步逃逸」：async 函数里 throw，调用方既不 await 也不 catch，
/// 这一层由 runZonedGuarded 接（见 main.dart 的 zone 回调）
Future<void> triggerAsyncEscape() async {
  throw StateError('异步逃逸：无人接住的 Future 异常');
}

/// 第三层「框架层」：build 阶段抛出的异常，
/// 这一层由 FlutterError.onError 接，页面上由 ErrorWidget.builder 兜渲染
class ExceptionLabPage extends StatefulWidget {
  const ExceptionLabPage({super.key});

  @override
  State<ExceptionLabPage> createState() => _ExceptionLabPageState();
}

class _ExceptionLabPageState extends State<ExceptionLabPage> {
  bool _breakBuild = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('三层异常触发')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // 按钮一：同步层，触发后日志立刻出现，界面毫无波澜
          FilledButton(
            onPressed: triggerSyncException,
            child: const Text('触发同步异常（try-catch 就地捕获）'),
          ),
          // 按钮二：异步逃逸，这里故意不 await、不 catch，
          // 异常会一路逃到 runZonedGuarded 的回调里
          FilledButton(
            onPressed: () {
              triggerAsyncEscape();
            },
            child: const Text('触发异步逃逸（交给 runZonedGuarded）'),
          ),
          // 按钮三：框架层，置位后下一个 build 抛异常，由 FlutterError 接
          FilledButton(
            onPressed: () {
              setState(() {
                _breakBuild = true;
              });
            },
            child: const Text('触发框架层异常（build 内抛出）'),
          ),
          if (_breakBuild) const _BuildBreaker(),
        ],
      ),
    );
  }
}

class _BuildBreaker extends StatelessWidget {
  const _BuildBreaker();

  @override
  Widget build(BuildContext context) {
    throw StateError('框架层：build 阶段故意抛出');
  }
}