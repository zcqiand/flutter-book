// 验证环境探针（不入书）：清单 11-5 生命周期成对纪律回执实抓（v2）。
// 被测对象=lib/main_11_5_probe.dart（清单 11-5 逐字复刻 + initState/dispose
// 探针打印，插入行已用 diff 备案）；回执由探针记录器逐字落盘
// test/receipts/receipt_11_5.txt，测试进程内直接写盘，非手抄。
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anim_lab/main_11_5_probe.dart';

final List<Object> _errors = <Object>[];

// 写盘放 tearDown（真异步区）：dart:io 的 Future 在 testWidgets 的
// FakeAsync 区内永不完成，v1 空回执与 v2 首跑挂起均由此起
void _writeReceipt() async {
  final File f = File('test/receipts/receipt_11_5.txt');
  await f.parent.create(recursive: true);
  await f.writeAsString('${probe115Log.join('\n')}\n', flush: true);
}

void main() {
  testWidgets('清单11-5 生命周期成对：push 触发 initState、pop 触发 dispose（时序实抓）',
      (WidgetTester tester) async {
    final void Function(FlutterErrorDetails)? original = FlutterError.onError;
    addTearDown(() => FlutterError.onError = original);
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is TestFailure) {
        original!(details);
        return;
      }
      _errors.add(details.exception);
    };

    // 入口占位页（清单 home 即生命周期页，探针外层入口才能演练进退）
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: Text('入口占位'))),
    ));
    await tester.pumpAndSettle();
    rec115('测试：入口占位页就绪，push 清单生命周期页');

    final NavigatorState nav =
        tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute<void>(builder: (_) => const LifecyclePage()));
    await tester.pump(); // 路由首帧（initState 在此执行）
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(FlutterLogo), findsOneWidget);
    final double scaleMid = tester
        .widget<Transform>(find.byType(Transform).first)
        .transform
        .getMaxScaleOnAxis();
    rec115('测试：push 后 200ms，缩放=${scaleMid.toStringAsFixed(3)}（initState 的 forward 已推进）');

    await tester.pumpAndSettle();
    final double scaleEnd = tester
        .widget<Transform>(find.byType(Transform).first)
        .transform
        .getMaxScaleOnAxis();
    rec115('测试：settle，缩放=${scaleEnd.toStringAsFixed(3)}（0.5+1.0×1.0 终态，进度到头）');
    expect(scaleEnd, moreOrLessEquals(1.5, epsilon: 0.01));

    rec115('测试：pop 指令发出');
    nav.pop();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(LifecyclePage), findsNothing);
    rec115('测试：页面离栈，全程 FlutterError=${_errors.length}');

    FlutterError.onError = original;

    // 时序断言：initState 在 push 后、dispose 在 pop 后，且各恰一次、顺序正确
    final List<String> log = probe115Log;
    final int iInit =
        log.indexWhere((String l) => l.contains('initState：控制器创建'));
    final int iPush = log.indexWhere((String l) => l.contains('push 清单生命周期页'));
    final int iDispStart =
        log.indexWhere((String l) => l.contains('dispose：开始释放'));
    final int iPop = log.indexWhere((String l) => l.contains('pop 指令发出'));
    expect(iInit, greaterThan(iPush));
    expect(iDispStart, greaterThan(iPop));
    expect(
        log.where((String l) => l.contains('initState：控制器创建')), hasLength(1));
    expect(log.where((String l) => l.contains('成对闭环')), hasLength(1));
    expect(_errors, isEmpty);
  });

  tearDown(_writeReceipt);
}
