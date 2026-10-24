// 【验证偏差注记】本文件与清单 8-1 唯一差异:去掉 body: const 的 const(清单原文 Container 非 const 构造,按字面编译不过,见 verify 报告);病灶本身(240 紧约束 vs 400 自报)一字未动。
// ============================================================
// 教学故意失败版本：本工程就是用来跑出 overflow 的。
// 先按正文 8.4 的操作序列跑一遍，亲眼看到右缘红黄条纹，
// 控制台报 A RenderFlex overflowed by 160 pixels on the right，
// 再对照清单 8-3 修复。
// 单文件自包含，零第三方依赖，flutter run -d windows 可跑。
// 【验证偏差注记】本文件与清单 8-1 唯一差异:去掉 body: const 的 const(清单原文 Container 非 const 构造,按字面编译不过,见 verify 报告);病灶本身(240 紧约束 vs 400 自报)一字未动。
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
      // 正文 8.2：SizedBox 给子节点下发的是紧约束——240×160 写死，
      // Row 只分到这一块地盘，一像素都多不出来
      body: Center(
        child: SizedBox(
          width: 240,
          height: 160,
          child: Row(
            children: <Widget>[
              // 正文 8.4：Row 在主轴上给子节点放的是无界约束，
              // 于是两枚 Container 各按自报的 200 排开，合计 400；
              // 紧约束地盘只有 240，超出的 160 像素就是 overflow 本尊
              Container(width: 200, color: Colors.orangeAccent),
              Container(width: 200, color: Colors.deepOrange),
            ],
          ),
        ),
      ),
    );
  }
}
