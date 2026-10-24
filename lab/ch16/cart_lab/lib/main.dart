// lib/main.dart
// ch16 cart_lab 入口：默认=四方案逐一切换演示页；exe 同目录存在 CART_PROBE.flag
// （或 CART_PROBE dart-define）时进入自驱动探针（跑完四组断言落 capture 后 exit(0)），
// 供 windows debug 直跑。探针日志写 exe 同目录 probe_capture.log。
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart_probe.dart';
import 'versions/bloc_version.dart';
import 'versions/inherited_version.dart';
import 'versions/riverpod_version.dart';
import 'versions/setstate_version.dart';

void main() {
  final Directory exeDir = File(Platform.resolvedExecutable).parent;
  final bool probeMode = File('${exeDir.path}\\CART_PROBE.flag').existsSync() ||
      const bool.fromEnvironment('CART_PROBE');
  if (probeMode) {
    runApp(CartProbeApp(logPath: '${exeDir.path}\\probe_capture.log'));
  } else {
    runApp(const CartLabApp());
  }
}

/// 四方案逐一切换演示页：同一购物车需求，四个版本入口并列
class CartLabApp extends StatefulWidget {
  const CartLabApp({super.key});
  @override
  State<CartLabApp> createState() => _CartLabAppState();
}

class _CartLabAppState extends State<CartLabApp> {
  int _current = 0;

  static const List<(String, Widget)> _versions = <(String, Widget)>[
    ('setState 版', SetStateCartPage()),
    ('InheritedWidget 版', CartContainer(child: InheritedCartPage())),
    ('Riverpod 版', ProviderScope(child: RiverpodCartPage())),
    ('Bloc 版', BlocCartPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cart_lab',
      home: Scaffold(
        appBar: AppBar(title: const Text('cart_lab：四方案同题共答')),
        body: Column(
          children: <Widget>[
            Wrap(
              children: <Widget>[
                for (int i = 0; i < _versions.length; i++)
                  TextButton(
                    onPressed: () => setState(() => _current = i),
                    child: Text(_versions[i].$1),
                  ),
              ],
            ),
            const Divider(height: 1),
            Expanded(child: _versions[_current].$2),
          ],
        ),
      ),
    );
  }
}
