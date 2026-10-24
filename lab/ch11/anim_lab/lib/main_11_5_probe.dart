// ============================================================
// 验证环境探针（不入书）：清单 11-5 逐字复刻 + initState/dispose 探针打印。
// 插入行仅 rec115(...) 调用与文件头记录器（diff 备案于 chapter-011.verify.md
// 第五节），清单逻辑零改动。供 verify_11_5_test.dart 驱动 push/pop 抓时序。
// ============================================================
// ============================================================
// 教学演示版本：正文 11.4 控制器生命周期纪律。
// 复现操作序列：
//   1. flutter create anim_lab，整文件替换 lib/main.dart；
//   2. flutter run -d windows，点「正放」「倒放」各试一次；
//   3. 退出页面，控制台不应出现 controller 相关的异常输出。
// 看什么：控制器的创建与释放各在哪个方法里；换 repeat 档时
//   代码只动注释标出的那一处。
// 单文件自包含，零第三方依赖。泄漏反例对照见正文 11.4，不在此重复。
// ============================================================
import 'package:flutter/material.dart';

// ---- 探针记录器（不入书）----
final List<String> probe115Log = <String>[];
final Stopwatch probe115Sw = Stopwatch()..start();
void rec115(String msg) {
  final String line = '[11-5] t=${probe115Sw.elapsedMilliseconds}ms $msg';
  probe115Log.add(line);
  debugPrint(line);
}


void main() {
  runApp(const AnimLabApp());
}

class AnimLabApp extends StatelessWidget {
  const AnimLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LifecyclePage(),
    );
  }
}

class LifecyclePage extends StatefulWidget {
  const LifecyclePage();

  @override
  State<LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<LifecyclePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // 选型分界（控制器自身的三档用法，代码落点都在 initState 之后）：
  // 1. forward()/reverse()：一次到位或原路退回，交互动画用这档，本例即是；
  // 2. repeat()：到头从头再来，加载转圈类需求用它，写法 _controller.repeat()；
  // 3. repeat(reverse: true)：到头倒着回来，呼吸灯类往返需求用它。
  // 需要精确时序控制（暂停、指定起点、分段衔接）时，只有控制器档做得到
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.forward();
    rec115('initState：控制器创建（vsync + 400ms），forward() 已启动');
  }

  @override
  void dispose() {
    // 成对纪律：initState 里建的，在这里原样还回去。
    // 不还的后果：控制器背后的资源随页面残存，7.3 的清理清单
    // 从本章起多一条硬项
    rec115('dispose：开始释放（先还控制器再调 super）');
    _controller.dispose();
    rec115('dispose：_controller.dispose() 完成，与 initState 成对闭环');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('控制器的建与还')),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Transform.scale(
              // 控制器 value 就是 0 到 1 的进度，直接当缩放系数用
              scale: 0.5 + _controller.value * 1.0,
              child: const FlutterLogo(size: 80),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FilledButton(
              onPressed: () => _controller.forward(),
              child: const Text('正放'),
            ),
            OutlinedButton(
              onPressed: () => _controller.reverse(),
              child: const Text('倒放'),
            ),
          ],
        ),
      ),
    );
  }
}
