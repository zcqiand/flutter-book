// ============================================================
// 修复版本：按清单 8-6 修复——Column 里给 ListView 外面包一层
// Expanded。基础体与清单 8-4 同源（const 偏差同 main_runnable.dart
// 的注记）。
// ============================================================
import 'package:flutter/material.dart';

void main() {
  runApp(const UnboundedLabApp());
}

class UnboundedLabApp extends StatelessWidget {
  const UnboundedLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UnboundedClinicPage(),
    );
  }
}

class UnboundedClinicPage extends StatelessWidget {
  const UnboundedClinicPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('约束诊所·unbounded 病房')),
      // 清单 8-6：Expanded 把 Column 分下来的剩余高度交给 ListView，
      // 「无限高」从此改写成「这块地有多高就滚多远」
      body: Column(
        children: <Widget>[
          const Text('今日病例列表'),
          Expanded(
            child: ListView(
              children: const <Widget>[
                ListTile(
                  leading: Icon(Icons.medical_services),
                  title: Text('病例一：Row 溢出 160 像素'),
                ),
                ListTile(
                  leading: Icon(Icons.assignment),
                  title: Text('病例二：Expanded 压扁兄弟'),
                ),
                ListTile(
                  leading: Icon(Icons.biotech),
                  title: Text('病例三：视口拿到无界高度'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
