// Widget 层：页面挂载与交互回归（ProviderScope 挂根 + ref.watch 重建）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:migrated/main.dart';

void main() {
  testWidgets('初始渲染：标题行与种子待办可见', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MigratedTodoApp()));

    expect(find.text('待办清单（迁移后）'), findsOneWidget);
    expect(find.text('学 Flutter'), findsOneWidget);
  });

  testWidgets('点浮动按钮追加一条待办，列表随之重建', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MigratedTodoApp()));

    expect(find.text('新待办'), findsNothing);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text('新待办'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}
