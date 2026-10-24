// 验证夹具：驱动清单 6-6 修复版（keybug_fixed/lib/main.dart，
// = 清单 6-4 字节原文 + 6-6 唯一改动 ValueKey<String>(_names[index])）。
// 同样三步操作：勾第 1、3 项 → 删第一项 → 断言勾选跟人走，无一人被冤枉。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:contacts_demo/main.dart';

bool rowChecked(WidgetTester tester, String name) {
  final CheckboxListTile tile =
      tester.widget(find.widgetWithText(CheckboxListTile, name));
  return tile.value ?? false;
}

void main() {
  testWidgets('清单6-6 ValueKey 修复：同样操作，勾选跟人走',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const KeyBugLabApp());
    await tester.pumpAndSettle();

    // 同样勾第 1、3 项（张伟、韩梅梅）
    await tester.tap(find.text('张伟'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('韩梅梅'));
    await tester.pumpAndSettle();
    expect(rowChecked(tester, '张伟'), isTrue);
    expect(rowChecked(tester, '韩梅梅'), isTrue);

    // 同样点「删除第一项」
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // 人删对了
    expect(find.text('张伟'), findsNothing);

    // 幸存的被勾者仍然勾着：韩梅梅前移到第 1 行，勾跟着人走
    expect(rowChecked(tester, '韩梅梅'), isTrue,
        reason: 'ValueKey 修复后勾选跟人走：韩梅梅虽前移仍保持勾选');

    // 无一人被冤枉：顶上来的李雷、王五都没有勾
    expect(rowChecked(tester, '李雷'), isFalse,
        reason: '李雷不应顶到任何勾');
    expect(rowChecked(tester, '王五'), isFalse,
        reason: '王五不应顶到任何勾');
    expect(rowChecked(tester, '赵敏'), isFalse);
    expect(rowChecked(tester, '刘洋'), isFalse);
    expect(rowChecked(tester, '陈静'), isFalse);
    expect(rowChecked(tester, '周杰'), isFalse);
  });
}
