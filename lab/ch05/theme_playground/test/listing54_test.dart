import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'listing54.fixture.dart';

/// 实测验证夹具：直接驱动清单 5-4 原文代码（DualStyleApp），
/// 验证 Material 与 Cupertino 双风格同页渲染与各自独立记账
void main() {
  testWidgets('清单5-4 双风格同页：两列并排、开关各记各的账', (tester) async {
    await tester.pumpWidget(const DualStyleApp());
    await tester.pumpAndSettle();

    // 双列标题并排
    expect(find.text('Material'), findsOneWidget);
    expect(find.text('Cupertino'), findsOneWidget);

    // 双风格组件同页各就各位
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(CupertinoButton), findsOneWidget);
    // SwitchListTile 内部含一个 Switch，加上 Material 列的 Switch 共 2 个
    expect(find.byType(Switch), findsNWidgets(2));
    expect(find.byType(CupertinoSwitch), findsOneWidget);

    // Cupertino 开关初始开，拨动后翻转为关（自己的账，独立记账）
    final cupSwitch = find.byType(CupertinoSwitch);
    expect(tester.widget<CupertinoSwitch>(cupSwitch).value, isTrue);
    await tester.tap(cupSwitch);
    await tester.pumpAndSettle();
    expect(tester.widget<CupertinoSwitch>(cupSwitch).value, isFalse);

    // Material 列开关不受牵连，仍为开
    final materialSwitch = find.byType(Switch).last;
    expect(tester.widget<Switch>(materialSwitch).value, isTrue);
  });
}
