// ============================================================
// 修复版本：按清单 8-3 修复——只动 Row 的第二枚盒子，
// 包一层 Expanded、摘掉写死的 width。基础体与清单 8-1 同源
// （const 偏差同 main_runnable.dart 的注记）。
// ============================================================
import 'package:flutter/material.dart';

void main() {
  runApp(const OverflowLabApp());
}

class OverflowLabApp extends StatelessWidget {
  const OverflowLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverflowClinicPage(),
    );
  }
}

class OverflowClinicPage extends StatelessWidget {
  const OverflowClinicPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('约束诊所·overflow 病房')),
      body: Center(
        child: SizedBox(
          width: 240,
          height: 160,
          // 清单 8-3：布局意图是第一枚定宽 200、第二枚吃掉剩余的 40；
          // Expanded 把 Row 分到的剩余宽度接过来再转发给子盒
          child: Row(
            children: <Widget>[
              Container(width: 200, color: Colors.orangeAccent),
              Expanded(
                child: Container(color: Colors.deepOrange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
