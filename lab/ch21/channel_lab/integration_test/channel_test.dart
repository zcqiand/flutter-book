// ch21 实测回执用 integration test：在真实 Windows 载体上程序化触发按钮。
// 与 flutter run 同载体（真实 Windows runner、真实平台通道设施），
// 无头会话下 OS 级键鼠注入不可用，故以 tester.tap 触发（UI 事件为真实命中）。
// 实测臂注：本文件为回执抓取专用，不进正文清单。
import 'package:channel_lab/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

List<String?> allTexts(WidgetTester tester) =>
    tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CH21-R1/R2/T05 battery channel + l10n toggle on real Windows runner',
      (tester) async {
    // API_BASE_URL 由 flutter test --dart-define 注入（与 flutter run 同一生效路径）
    await tester.pumpWidget(const ChannelLabApp());
    await tester.pumpAndSettle();

    debugPrint('RECEIPT zh initial: allTexts=${allTexts(tester)}');

    // —— 触发读取电量：预期 Windows 无平台实现 → MissingPluginException ——
    await tester.tap(find.text('读取电量'));
    await tester.pumpAndSettle();
    debugPrint('RECEIPT zh after-tap: allTexts=${allTexts(tester)}');

    // —— 切英文：T05 英文态 ——
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    debugPrint('RECEIPT en toggled: allTexts=${allTexts(tester)}');
    expect(find.text('Read Battery'), findsOneWidget);

    // —— 英文态再读一次：MissingPluginException 英文文案 ——
    await tester.tap(find.text('Read Battery'));
    await tester.pumpAndSettle();
    debugPrint('RECEIPT en after-tap: allTexts=${allTexts(tester)}');

    expect(find.textContaining('not implemented'), findsOneWidget);
  });
}
