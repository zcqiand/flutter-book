// 验证夹具：驱动清单 6-4（keybug_nokey/lib/main.dart，字节级原文，无 key 版）。
// 复现章内三步操作序列：勾第 1、3 项（张伟、韩梅梅）→ 点「删除第一项」→ 观察勾选错位。
// 断言错位确实发生：勾选留在原屏幕行位，扣给顶上来的李雷、王五。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:contacts_demo/main.dart';

bool rowChecked(WidgetTester tester, String name) {
  final CheckboxListTile tile =
      tester.widget(find.widgetWithText(CheckboxListTile, name));
  return tile.value ?? false;
}

void main() {
  testWidgets('清单6-4 无 key 错位复现：勾 1、3 项 → 删第一项 → 勾选扣给顶上来的两位',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const KeyBugLabApp());
    await tester.pumpAndSettle();

    // 第一步：勾第 1 项（张伟）、第 3 项（韩梅梅）
    await tester.tap(find.text('张伟'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('韩梅梅'));
    await tester.pumpAndSettle();
    expect(rowChecked(tester, '张伟'), isTrue, reason: '第 1 项已勾');
    expect(rowChecked(tester, '韩梅梅'), isTrue, reason: '第 3 项已勾');
    expect(rowChecked(tester, '李雷'), isFalse, reason: '第 2 项未勾');

    // 第二步：点 AppBar 右上角「删除第一项」
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // 人删对了：张伟没了，名单剩七个
    expect(find.text('张伟'), findsNothing, reason: '张伟已删除');
    expect(find.text('李雷'), findsOneWidget);
    expect(find.text('王五'), findsOneWidget);

    // 第三步：勾选留在原屏幕行位，扣给顶上来的新住户
    // 屏幕第 0 行原是张伟（勾），现在坐着李雷——勾被扣给李雷
    expect(rowChecked(tester, '李雷'), isTrue,
        reason: '错位坐实：李雷从没被点过，却顶了张伟的勾');
    // 屏幕第 2 行原是韩梅梅（勾），现在坐着王五——勾被扣给王五
    expect(rowChecked(tester, '王五'), isTrue,
        reason: '错位坐实：王五从没被点过，却顶了韩梅梅的勾');
    // 本人反而丢了勾：韩梅梅前移到第 1 行，勾没跟人走
    expect(rowChecked(tester, '韩梅梅'), isFalse,
        reason: '勾选跟座位走、不跟人走：韩梅梅本人已失去勾选');
    // 其余四行不受影响（赵敏、刘洋、陈静、周杰原本就没勾，仍在原相对位之后）
    expect(rowChecked(tester, '赵敏'), isFalse);
    expect(rowChecked(tester, '刘洋'), isFalse);
    expect(rowChecked(tester, '陈静'), isFalse);
    expect(rowChecked(tester, '周杰'), isFalse);
  });
}
