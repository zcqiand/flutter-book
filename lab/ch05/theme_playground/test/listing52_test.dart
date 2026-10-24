import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'listing52.fixture.dart';

/// 实测验证夹具：直接驱动清单 5-2 原文代码（DarkModeApp），
/// 验证「拨一下开关，全 App 换装」的运行时行为
void main() {
  testWidgets('清单5-2 暗色一键切换：亮 -> 暗 -> 亮', (tester) async {
    await tester.pumpWidget(const DarkModeApp());
    await tester.pumpAndSettle();

    Brightness scaffoldBrightness() =>
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

    // 初始亮色
    expect(scaffoldBrightness(), Brightness.light);
    expect(find.text('暗色模式'), findsOneWidget);

    // 拨开关 -> 暗
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(scaffoldBrightness(), Brightness.dark);
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).colorScheme.secondary,
        isNot(Theme.of(tester.element(find.byType(Scaffold).first)).colorScheme.primary));

    // 拨回 -> 亮
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(scaffoldBrightness(), Brightness.light);
  });
}
