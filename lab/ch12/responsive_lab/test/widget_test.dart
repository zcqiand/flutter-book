import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:responsive_lab/main.dart';

void main() {
  // 回执 A 的 widget test 轨: 三档断点各自命中预期布局
  group('AdaptiveDemoPage 三档断点', () {
    Future<void> pumpAtWidth(WidgetTester tester, double width) async {
      // 测试表面默认 800x600, 会把超宽 SizedBox 钳回 800(小于 840 断点),
      // 先放大逻辑表面再 pump, 保证 1000 宽真的以 1000 递下来
      tester.view.physicalSize = Size(width + 100, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              height: 600,
              child: const AdaptiveDemoPage(),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('宽度 400 命中手机竖屏单列', (WidgetTester tester) async {
      await pumpAtWidth(tester, 400);
      expect(find.text('今日概览'), findsOneWidget);
      expect(find.text('详情面板'), findsNothing);
    });

    testWidgets('宽度 700 命中平板双栏', (WidgetTester tester) async {
      await pumpAtWidth(tester, 700);
      expect(find.text('内容区'), findsOneWidget);
      expect(find.text('今日概览'), findsNothing);
    });

    testWidgets('宽度 1000 命中桌面三栏', (WidgetTester tester) async {
      await pumpAtWidth(tester, 1000);
      expect(find.text('详情面板'), findsOneWidget);
      expect(find.text('内容区'), findsNothing);
    });
  });

  group('RebuildLab 两版按键行为', () {
    testWidgets('问题版: 单次按键计数 +1, 页面可用', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RebuildLabPage()));
      expect(find.text('点击了 0 次'), findsOneWidget);
      await tester.tap(find.text('再点一次'));
      await tester.pump();
      expect(find.text('点击了 1 次'), findsOneWidget);
    });

    testWidgets('修复版: 单次按键计数 +1, 页面可用', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RebuildLabFixedPage()));
      expect(find.text('点击了 0 次'), findsOneWidget);
      await tester.tap(find.text('再点一次'));
      await tester.pump();
      expect(find.text('点击了 1 次'), findsOneWidget);
    });
  });
}
