// ============================================================
// 教学演示版本：正文 11.5 实战，本章留存物组件。
// 复现操作序列：
//   1. flutter create anim_lab，整文件替换 lib/main.dart；
//   2. flutter run -d windows；
//   3. 点「+20%」数次到顶，再点「归零」，观察进度条的
//      加速段与减速段（easeOutCubic 的手感）。
// 看什么：外部只给 value 目标值，组件内部自己决定怎么走过去；
//   控制器的建、随参数变化的续放、释放，三处都在这个文件里。
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
      home: CurveProgressDemo(),
    );
  }
}

/// 带缓动的进度条组件。
/// 外部只声明目标进度 [value]，当前值到目标值之间怎么走
/// 由 [curve] 与 [duration] 决定，外部不需要也不应该关心过程
class CurveProgressBar extends StatefulWidget {
  const CurveProgressBar({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  /// 目标进度，取值 0 到 1，超出部分按边界处理
  final double value;
  final Duration duration;
  final Curve curve;

  @override
  State<CurveProgressBar> createState() => _CurveProgressBarState();
}

class _CurveProgressBarState extends State<CurveProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      // 首帧直接落在初始进度上，不做从 0 爬升的假动画
      value: widget.value.clamp(0.0, 1.0),
    );
  }

  @override
  void didUpdateWidget(CurveProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 父组件给了新目标值才动：外部改一次 value，这里续放一次动画。
    // duration 是可变属性，参数变了要同步给控制器再放
    if (widget.value != oldWidget.value) {
      _controller
        ..duration = widget.duration
        ..animateTo(widget.value.clamp(0.0, 1.0), curve: widget.curve);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // 轨道宽度乘以当前进度，得到填充宽度：
            // 组件不写死宽度，交给父组件给的约束，哪里都能放
            final double trackWidth = constraints.maxWidth;
            final double fillWidth = trackWidth * _controller.value;
            return Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.centerLeft,
              child: Container(
                width: fillWidth,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 演示宿主：三个按钮改 value，其余全是组件内部的事
class CurveProgressDemo extends StatefulWidget {
  const CurveProgressDemo();

  @override
  State<CurveProgressDemo> createState() => _CurveProgressDemoState();
}

class _CurveProgressDemoState extends State<CurveProgressDemo> {
  double _value = 0.2;

  void _bump(double delta) {
    setState(() => _value = (_value + delta).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CurveProgressBar')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CurveProgressBar(value: _value),
            const SizedBox(height: 8),
            Text('进度 ${(_value * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FilledButton(
                  onPressed: () => _bump(0.2),
                  child: const Text('+20%'),
                ),
                OutlinedButton(
                  onPressed: () => _bump(-0.2),
                  child: const Text('-20%'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _value = 0),
                  child: const Text('归零'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
