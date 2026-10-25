// ============================================================
// 教学演示版本：正文 11.2 Hero 转场之源页（与清单 11-4 配对使用）。
// 复现操作序列：
//   1. flutter create anim_lab；
//   2. 用本文件替换 lib/main.dart，清单 11-4 存为 lib/detail_page.dart；
//   3. flutter run -d windows，点按列表任意一行。
// 看什么：方形色块如何从列表行「飞」到详情页放大位；
//   飞行的前提只有一个：两页各放一个同名 tag 的 Hero。
// 单文件自包含（仅依赖同工程的 detail_page.dart），零第三方依赖。
// ============================================================
import 'package:flutter/material.dart';

import 'detail_page.dart';

void main() {
  runApp(const AnimLabApp());
}

class AnimLabApp extends StatelessWidget {
  const AnimLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HeroSourcePage(),
    );
  }
}

class HeroSourcePage extends StatelessWidget {
  const HeroSourcePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('素材列表')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 8,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              // Hero 的 tag 是两页之间的接头暗号，必须逐字一致；
              // child 包什么，飞行时就搬什么
              leading: Hero(
                tag: 'hero-box-$index',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.primaries[index % Colors.primaries.length]
                        .shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              title: Text('素材 $index'),
              // push 一行即够，本章只看飞行衔接这一面
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => DetailPage(index: index),
                ));
              },
            ),
          );
        },
      ),
    );
  }
}