// 验证 harness（verify 卡任务 3/5）：行为判据走 widget test。
// 病灶判据：pump 清单 8-4 布局（main_runnable.dart，与清单唯一差异是去 const）
// 必触发 Vertical viewport was given unbounded height；
// 修复判据：pump 清单 8-6 布局（main_fixed.dart）零报错，
// 且在缩小窗口让内容超出视口后可实际滚动（pixels 前进）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbounded_lab/main_fixed.dart' as fixed;
import 'package:unbounded_lab/main_runnable.dart' as disease;

void main() {
  testWidgets('病灶版：Column 直接塞 ListView，必报 unbounded height', (tester) async {
    final errors = <FlutterErrorDetails>[];
    FlutterError.onError = (details) => errors.add(details);
    await tester.pumpWidget(const disease.UnboundedLabApp());
    await tester.pump();
    expect(errors, isNotEmpty, reason: '病灶版必须触发 unbounded height 断言');
    expect(
      errors.map((e) => e.toString()).join('\n'),
      contains('Vertical viewport was given unbounded height'),
    );
  });

  testWidgets('修复版：Expanded 包住 ListView——零报错且视口有界可滚动', (tester) async {
    // 零报错判据：不覆写 FlutterError.onError，任何布局断言直接判本测试失败

    // 缩小窗口（240×150 逻辑尺寸）：3 条病例(约168高)超出视口，滚动才有可验证的量
    tester.view.physicalSize = const Size(480, 300);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const fixed.UnboundedLabApp());
    await tester.pump();

    // 视口拿到的是有界高度：ListView 高度有限且小于窗口（上面还有标题文本）
    final list = tester.renderObject(find.byType(ListView)) as RenderBox;
    expect(list.size.height.isFinite, isTrue);
    expect(list.size.height, lessThan(150.0));

    // 滚动行为：上拖后 pixels 前进（视口真的在界内滚动了）
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
    expect(scrollable.position.pixels, 0.0);
    await tester.drag(find.byType(ListView), const Offset(0, -120));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0.0),
        reason: 'Expanded 给足有界地盘后，ListView 应能实际滚动');
  });
}
