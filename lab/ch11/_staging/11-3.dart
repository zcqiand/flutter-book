// ============================================================
// 教学演示版本：正文 11.2 Hero 转场之目标页（与清单 11-2 配对使用）。
// 看什么：与源页两处对应关系：
//   1. tag 逐字相同：'hero-box-$index'；
//   2. Hero 的 child 是同色圆角色块，仅尺寸从 56 放大到 200，
//      两页尺寸差正是飞行路径与缩放效果的来源。
// 零第三方依赖，存入 anim_lab/lib/ 与清单 11-2 同工程即可运行。
// ============================================================
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('素材 $index 详情')),
      body: Center(
        child: Hero(
          // 接头暗号：与源页逐字一致，同名 Hero 才能接上飞行
          tag: 'hero-box-$index',
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.primaries[index % Colors.primaries.length]
                  .shade300,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }
}
