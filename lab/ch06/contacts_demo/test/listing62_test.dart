// 验证夹具：驱动清单 6-2（contacts_demo/lib/main.dart，字节级原文）。
// 非交互桌面会话无法真实截屏/点击，行为验证以 widget test 等价执行（ch5 先例）。
// 验证点：①过滤前后列表项数断言；②collection-if 计数行只在有输入时存在；
// ③惰性构建：初始只建视口内若干项（<24），滚动后远处项现建。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:contacts_demo/main.dart';

void main() {
  testWidgets('清单6-2 过滤前后列表项数 + collection-if 计数行 + 惰性构建',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ContactFilterApp());
    await tester.pumpAndSettle();

    // 空查询：collection-if 计数行整个不进列表（连占位都没有）
    expect(find.textContaining('找到'), findsNothing,
        reason: '无输入时计数行不应存在（collection-if）');
    // 24 人名单，惰性构建：初始只建视口内的行，不到 24 个 ListTile
    final int builtInitially = tester.widgetList(find.byType(ListTile)).length;
    expect(builtInitially, lessThan(24),
        reason: 'ListView.builder 惰性构建：初始只建视口内可见项');
    expect(find.text('张伟'), findsOneWidget, reason: '首项在视口内已建');

    // 输入「王」→ 只剩 2 位（王芳、王强），计数行出现
    await tester.enterText(find.byType(TextField), '王');
    await tester.pumpAndSettle();
    expect(find.text('找到 2 位联系人'), findsOneWidget,
        reason: 'collection-if 计数行在输入后出现');
    expect(find.text('王芳'), findsOneWidget);
    expect(find.text('王强'), findsOneWidget);
    expect(find.text('张伟'), findsNothing, reason: '姓张的应被过滤掉');
    expect(tester.widgetList(find.byType(ListTile)).length, 2,
        reason: '过滤后列表项数应为 2');

    // 输入无匹配串 → 空态三元给「无匹配联系人」
    await tester.enterText(find.byType(TextField), '囧');
    await tester.pumpAndSettle();
    expect(find.text('找到 0 位联系人'), findsOneWidget);
    expect(find.text('无匹配联系人'), findsOneWidget);

    // 清空 → 回全量名单，计数行消失
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.textContaining('找到'), findsNothing);
    expect(find.text('张伟'), findsOneWidget);

    // 滚到名单末尾：滚到哪建到哪，第 24 位曹阳现建现用
    // （页面有两个 Scrollable：TextField 内层一个、ListView 一个，故直接对 ListView 拖）
    expect(find.text('曹阳'), findsNothing, reason: '视口外未构建（惰性）');
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('曹阳'), findsOneWidget, reason: '滚动后远处项现建');
  });
}
