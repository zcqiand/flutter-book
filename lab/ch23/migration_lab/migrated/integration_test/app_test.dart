// 集成层：真机/桌面载体端到端回归（flutter test integration_test -d windows）
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:migrated/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('端到端：启动即见基线种子待办，交互追加后列表增长',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MigratedTodoApp()));
    await tester.pumpAndSettle();

    expect(find.text('学 Flutter'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('新待办'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}
