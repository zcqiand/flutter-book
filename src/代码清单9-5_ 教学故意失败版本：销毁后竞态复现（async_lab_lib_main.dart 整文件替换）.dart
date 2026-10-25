// ============================================================
// 教学故意失败版本：本工程就是用来跑出销毁后竞态的。
// 复现操作序列（正文 9.4）：
//   1. flutter run -d windows；
//   2. 点「打开慢汇报页」进入下一页；
//   3. 3 秒内立刻按返回键，回首页后盯着控制台等满 3 秒；
//   4. 控制台甩出 setState() called after dispose() 断言（见配套回执）。
// 看完现象再对照清单 9-7 的 mounted 修复版。
// 单文件自包含，零第三方依赖。
// ============================================================
import 'package:flutter/material.dart';

void main() {
  runApp(const AsyncLabApp());
}

class AsyncLabApp extends StatelessWidget {
  const AsyncLabApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RaceHomePage(),
    );
  }
}

class RaceHomePage extends StatelessWidget {
  const RaceHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('竞态复现 · 首页')),
      body: Center(
        child: ElevatedButton(
          child: const Text('打开慢汇报页（进去后 3 秒内按返回键）'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RaceDetailPage()),
            );
          },
        ),
      ),
    );
  }
}

class RaceDetailPage extends StatefulWidget {
  const RaceDetailPage();

  @override
  State<RaceDetailPage> createState() => _RaceDetailPageState();
}

class _RaceDetailPageState extends State<RaceDetailPage> {
  String _report = '慢汇报还没到，请在 3 秒内按返回键';

  @override
  void initState() {
    super.initState();
    // 埋雷：3 秒后才执行的异步回调，此刻并不知道页面还活着没有
    Future<void>.delayed(const Duration(seconds: 3), () {
      // 病灶：对已销毁的 State 调 setState。
      // setState 的断言先炸，回调到此中断，下面的 showDialog 永远执行不到；
      // 若把弹窗那行挪到 setState 前面，弹窗就会真的盖在一个
      // 已经关闭的页面上，现象更吓人（正文 9.4 时序图即此局）
      setState(() {
        _report = '慢汇报已到达';
      });
      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('迟到的弹窗'),
          content: Text('页面都关了，我还弹出来了'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('慢汇报页')),
      body: Center(child: Text(_report)),
    );
  }
}