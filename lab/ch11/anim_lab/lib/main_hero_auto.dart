// ============================================================
// 验证环境探针（不入书）：清单 11-2+11-3 的 windows 轨自动驱动 harness。
// 结构复刻清单 11-2（同名 Hero + detail_page.dart），仅加自动导航驱动与
// 时间戳打印，供 flutter run -d windows 在无交互桌面会话下抓飞行回执。
// ============================================================
import 'dart:async';

import 'package:flutter/material.dart';

import 'detail_page.dart';

void main() {
  runApp(const HeroAutoApp());
}

class HeroAutoApp extends StatelessWidget {
  const HeroAutoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HeroAutoPage(),
    );
  }
}

class HeroAutoPage extends StatefulWidget {
  const HeroAutoPage({super.key});

  @override
  State<HeroAutoPage> createState() => _HeroAutoPageState();
}

class _HeroAutoPageState extends State<HeroAutoPage> {
  bool _scheduled = false;

  void _log(String msg) {
    final DateTime now = DateTime.now();
    // ignore: avoid_print
    print('[${now.toIso8601String()}] [auto] $msg');
  }

  void _scheduleAuto(BuildContext context) {
    if (_scheduled) return;
    _scheduled = true;
    _log('窗口已启动：素材列表渲染完成（8 行，各含 Hero hero-box-i）');
    Timer(const Duration(milliseconds: 1500), () {
      _log('push DetailPage(index:1) → Hero(hero-box-1) 飞行开始（框架接管）');
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const DetailPage(index: 1),
      ));
    });
    Timer(const Duration(milliseconds: 4500), () {
      _log('详情页已落位 3 秒，自动 pop 返回列表（Hero 逆向归位）');
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('素材列表')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 8,
        itemBuilder: (BuildContext context, int index) {
          // 首帧后启动自动导航驱动（仅探针，非清单内容）
          if (index == 0) {
            _scheduleAuto(context);
          }
          return Card(
            child: ListTile(
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
