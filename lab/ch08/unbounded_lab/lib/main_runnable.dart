// 【验证偏差注记】本文件与清单 8-4 唯一差异:去掉 body: const 的 const(清单原文 ListView/ListTile 非 const 构造,按字面编译不过,见 verify 报告);病灶本身(Column 无界约束 vs ListView 吃满)一字未动。
// ============================================================
// 教学故意失败版本：本工程就是用来跑出 unbounded height 的。
// 先按正文 8.5 的操作序列跑一遍，亲眼看控制台抛出
// Vertical viewport was given unbounded height，
// 再对照清单 8-6 修复。
// 单文件自包含，零第三方依赖，flutter run -d windows 可跑。
// 【验证偏差注记】本文件与清单 8-4 唯一差异:去掉 body: const 的 const(清单原文 ListView/ListTile 非 const 构造,按字面编译不过,见 verify 报告);病灶本身(Column 无界约束 vs ListView 吃满)一字未动。
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
      body: Column(
        children: <Widget>[
          Text('今日病例列表'),
          // 正文 8.5：病灶在两层约束的接力上——Column 给非弹性子节点的
          // 主轴高度约束是无界的（「你要多高我说不上来」），
          // 而 ListView 这类视口偏要吃满约束给的地盘再谈滚动，
          // 拿着「无限高」去吃满，布局当场卡死
          ListView(
            children: <Widget>[
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
        ],
      ),
    );
  }
}
