// ============================================================
// 教学演示版本：正文 11.3 显式动画三件套。
// 复现操作序列：
//   1. flutter create anim_lab，整文件替换 lib/main.dart；
//   2. flutter run -d windows；
//   3. 点「正放」看方块从 60 长到 240，点「倒放」原路退回，
//      连点正放观察每次都从头开始（forward(from: 0)）。
// 看什么：三者分工：控制器只推进度，Tween 定起止值，
//   Curve 定这段路怎么走（先快后慢、过冲回弹都由它决定）。
// 单文件自包含，零第三方依赖。
// ============================================================
import 'package:flutter/material.dart';

void main() {
  runApp(const AnimLabApp());
}

class AnimLabApp extends StatelessWidget {
  const AnimLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TweenPlayPage(),
    );
  }
}

class TweenPlayPage extends StatefulWidget {
  const TweenPlayPage();

  @override
  State<TweenPlayPage> createState() => _TweenPlayPageState();
}

// SingleTickerProviderStateMixin：本页只有一个控制器时挂它，
// vsync 参数接 this，作用是页面不在前台时停掉动画，防离屏浪费
class _TweenPlayPageState extends State<TweenPlayPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Tween 给出数值区间 60 到 240，CurvedAnimation 决定区间内怎么走：
    // easeOutBack 会冲过终点再弹回来，直线插值（Curves.linear）没有这个效果
    _width = Tween<double>(begin: 60, end: 240).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('显式动画三件套')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            // 每次控制器数值变化，builder 重新执行，取当前值摆 UI
            child: AnimatedBuilder(
              animation: _width,
              builder: (BuildContext context, Widget? child) {
                return Container(
                  width: _width.value,
                  height: 56,
                  color: Colors.teal,
                  alignment: Alignment.center,
                  child: Text('宽度 ${_width.value.toStringAsFixed(0)}'),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FilledButton(
                // from: 0 表示每次从起点重放；不传则从当前进度续放
                onPressed: () => _controller.forward(from: 0),
                child: const Text('正放'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _controller.reverse,
                child: const Text('倒放'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
