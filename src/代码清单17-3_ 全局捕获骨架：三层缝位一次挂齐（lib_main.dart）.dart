// lib/main.dart
// guard_lab 骨架：三个全局缝位在 main 里一次挂齐，本章所有演练页都跑在这张安全网下
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'demo/crash_lab.dart';
import 'demo/exception_lab.dart';

void main() {
  // 缝位一「框架层」：Widget 构建期抛出的异常由 FlutterError 接管。
  // 只打结构化日志，presentError 保留完整调试信息，开发期红屏才有的看
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('[guard_lab][framework] ${details.exception}');
    FlutterError.presentError(details);
  };

  // 缝位二「构建兜底」：某个 Widget build 失败后页面上渲染什么由它决定。
  // 开发期保留显眼红屏方便定位，生产期收敛成一句可读文案，不让用户看到堆栈
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      return const ColoredBox(
        color: Color(0xFF9E9E9E),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                '页面出了点问题，我们正在修复',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
    return ErrorWidget(details.exception);
  };

  // 缝位三「异步逃逸」：runZonedGuarded 兜异步逃逸异常，
  // 未被任何 try-catch 接住的 Future 异常会落到 zone 的这个回调里
  runZonedGuarded(() {
    runApp(const GuardLabApp());
  }, (Object error, StackTrace stackTrace) {
    debugPrint('[guard_lab][zone] $error');
  });
}

class GuardLabApp extends StatelessWidget {
  const GuardLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'guard_lab',
      theme: ThemeData(useMaterial3: true),
      home: const GuardLabHomePage(),
    );
  }
}

class GuardLabHomePage extends StatelessWidget {
  const GuardLabHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('guard_lab')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('三层异常触发演示'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (BuildContext context) => const ExceptionLabPage(),
              ));
            },
          ),
          ListTile(
            title: const Text('分区降级边界演练'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (BuildContext context) => const CrashLabPage(),
              ));
            },
          ),
        ],
      ),
    );
  }
}