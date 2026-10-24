// ============================================================
// 倒计时实验室：父组件持「总时长」配置，子组件持倒计时账。
// 三大生命周期回调各司其职（正文 7.2 表 7-1）：
//   initState 只做一次性启动；
//   didUpdateWidget 只管配置变化；
//   dispose 只管对账收表。
// 单文件自包含，零第三方依赖，flutter run -d windows 可跑。
// ============================================================
import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const CountdownLabApp());
}

class CountdownLabApp extends StatelessWidget {
  const CountdownLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CountdownPage(),
    );
  }
}

/// 父组件只持配置不碰秒数：60 还是 30，账记在这里。
/// 配置与展示分家，切换时剩余秒的重置是子组件在
/// didUpdateWidget 里自己的事，父组件不代劳（正文 7.2）
class CountdownPage extends StatefulWidget {
  const CountdownPage();

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  int _totalSeconds = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('倒计时实验室')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 两枚按钮只改一份配置：setState 的闭包里没有 _remainingSeconds，
              // 父子职责边界在按钮的回调里就已经守住
              FilledButton(
                onPressed: () => setState(() => _totalSeconds = 60),
                child: const Text('60 秒'),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: () => setState(() => _totalSeconds = 30),
                child: const Text('30 秒'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 配置下发全走构造参数这一条通道；
          // 子组件拿新旧对比决定要不要重置，无关重建打扰不到倒计时
          CountdownDisplay(totalSeconds: _totalSeconds),
        ],
      ),
    );
  }
}

/// 子组件承载倒计时展示：剩余秒与 Timer 都记在自己的 State 里
class CountdownDisplay extends StatefulWidget {
  const CountdownDisplay({super.key, required this.totalSeconds});

  final int totalSeconds;

  @override
  State<CountdownDisplay> createState() => _CountdownDisplayState();
}

class _CountdownDisplayState extends State<CountdownDisplay> {
  Timer? _timer;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    // 正文 7.2：initState 只做一次性启动。初始剩余秒直接取自
    // widget.totalSeconds，不从写死的默认值猜，配置从出生就对
    _remainingSeconds = widget.totalSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 正文 7.2 表 7-1：配置变化专属回调。拿旧配置对比，总时长真变了才重置；
    // 父组件因为别的 setState 重建过来时新旧相等，直接放过，
    // 倒计时不会被无关重建打断归零
    if (oldWidget.totalSeconds != widget.totalSeconds) {
      _remainingSeconds = widget.totalSeconds;
      _startTimer();
    }
  }

  void _startTimer() {
    // 重启前先 cancel 旧表：periodic 不会去重，叠两只表每秒就扣两次。
    // 「谁启动谁 cancel」在这里是防御性的，在 dispose 里是保命性的（正文 7.5）
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remainingSeconds <= 1) {
        // 走到 0 就摘表：不清的话定时器空转，平白耗着一条回调
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  @override
  void dispose() {
    // 正文 7.2 表 7-1：dispose 是唯一的对账窗口。Timer 持着这个 State 的
    // 回调，不 cancel 它就带着整条引用链活在页面之外；
    // 正文 7.5 的泄漏，缺的正是这四行
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_remainingSeconds',
      style: Theme.of(context).textTheme.displayLarge,
    );
  }
}
