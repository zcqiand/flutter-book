// ch7 countdown_lab 行为验证（widget test 等价判据，替代非交互环境无法点击的窗口操作）
import 'package:countdown_lab/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('初始 60 满格起跳，无关重建不打断倒计时', (WidgetTester tester) async {
    await tester.pumpWidget(const CountdownLabApp());
    expect(find.text('60'), findsOneWidget);

    // 走两秒，确认逐秒递减
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('58'), findsOneWidget);

    // 点「30 秒」：真改配置 → 立刻重置成 30 满格
    await tester.tap(find.text('30 秒'));
    await tester.pump();
    expect(find.text('30'), findsOneWidget);

    // 再点一次「30 秒」（新旧配置相等 = 无关重建）→ 不重置，继续走
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('28'), findsOneWidget);
    await tester.tap(find.text('30 秒'));
    await tester.pump();
    expect(find.text('28'), findsOneWidget);
  });

  testWidgets('走到 0 表自己停住；中途切回 60 满格重来', (WidgetTester tester) async {
    await tester.pumpWidget(const CountdownLabApp());
    await tester.tap(find.text('30 秒'));
    await tester.pump();

    // 走满 30 秒到 0
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('0'), findsOneWidget);

    // 再走 3 秒：定时器已摘表，停在 0 不变负
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('0'), findsOneWidget);

    // 切回「60 秒」：满格重来
    await tester.tap(find.text('60 秒'));
    await tester.pump();
    expect(find.text('60'), findsOneWidget);
  });
}
