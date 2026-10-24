// test/crash_lab_test.dart
// 清单 17-5 崩溃兜底前后对照：widget test 断言分区降级——崩溃子树原地换降级卡、
// 同级兄弟仍响应；前后两态各留断言记录，回执落盘 test/receipts/17_5_crash.txt。
// 注意：CrashBoundary 的 childBuilder 在父级 setState 后随重建自动重跑，
// 「复位故障源」即触发子树恢复，无需再点重试（清单 17-4 行为，实测坐实）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guard_lab/demo/crash_lab.dart';

import 'receipt.dart';

void main() {
  testWidgets('分区降级：崩溃前后对照七步（清单17-5）', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final List<String> lines = <String>['RECEIPT_BEGIN|17_5_crash'];
    Future<void> step(String label, String actual, String expected) async {
      final bool ok = actual == expected;
      lines.add('STEP|$label|actual=$actual|expected=$expected|${ok ? 'PASS' : 'FAIL'}');
      expect(ok, isTrue, reason: '$label: actual=$actual');
    }

    await tester.pumpWidget(const MaterialApp(home: CrashLabPage()));
    await tester.pumpAndSettle();

    // step1 按下前：页面完整，子树正常卡与边界外文字都在
    final bool normalBefore = find.text('子树运行正常').evaluate().isNotEmpty;
    final bool outerBefore = find.text('边界外的这行字始终可读：局部崩、全局活').evaluate().isNotEmpty;
    await step('step1-按下前-页面完整', '子树正常=${normalBefore ? '可见' : '缺失'},边界外文字=${outerBefore ? '可见' : '缺失'}', '子树正常=可见,边界外文字=可见');

    // step2 按下「人为崩溃」：崩掉子树原地换降级卡
    await tester.tap(find.text('人为崩溃：让子树 build 抛异常'));
    await tester.pumpAndSettle();
    final bool degraded = find.text('该区域暂时不可用，其余功能不受影响').evaluate().isNotEmpty;
    final bool retryBtn = find.widgetWithText(TextButton, '重试').evaluate().isNotEmpty;
    await step('step2-按下后-降级卡', '降级卡=${degraded ? '出现' : '缺失'},重试按钮=${retryBtn ? '在' : '缺'}', '降级卡=出现,重试按钮=在');

    // step3 崩溃后：子树原文本消失（原地替换而非叠加）
    final bool normalGone = find.text('子树运行正常').evaluate().isEmpty;
    await step('step3-崩溃后-子树原文本', normalGone ? '已替换' : '仍在', '已替换');

    // step4 崩溃后：边界外文字与两个操作按钮仍在（兄弟未受波及）
    final bool outerAfter = find.text('边界外的这行字始终可读：局部崩、全局活').evaluate().isNotEmpty;
    final bool btnsAfter = find.text('人为崩溃：让子树 build 抛异常').evaluate().isNotEmpty &&
        find.text('复位故障源（再点重试恢复子树）').evaluate().isNotEmpty;
    await step('step4-崩溃后-兄弟存活', '边界外文字=${outerAfter ? '可见' : '缺失'},两按钮=${btnsAfter ? '齐' : '缺'}', '边界外文字=可见,两按钮=齐');

    // step5 兄弟按钮仍可交互：点「复位故障源」→ 父级重建重跑 childBuilder，子树自动恢复
    await tester.tap(find.text('复位故障源（再点重试恢复子树）'));
    await tester.pumpAndSettle();
    final bool recovered = find.text('子树运行正常').evaluate().isNotEmpty;
    final bool degradedGone = find.text('该区域暂时不可用，其余功能不受影响').evaluate().isEmpty;
    await step('step5-复位后-子树恢复', '子树正常=${recovered ? '回来' : '缺失'},降级卡=${degradedGone ? '消失' : '仍在'}', '子树正常=回来,降级卡=消失');

    // step6 再次人为崩溃：故障源在场时点「重试」仍降级（重试不掩盖故障）
    await tester.tap(find.text('人为崩溃：让子树 build 抛异常'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '重试'));
    await tester.pumpAndSettle();
    final bool stillDegraded = find.text('该区域暂时不可用，其余功能不受影响').evaluate().isNotEmpty;
    await step('step6-故障源在场点重试', stillDegraded ? '仍降级' : '被掩盖', '仍降级');

    // step7 再次复位：子树恢复，降级卡消失，页面回到完整体
    await tester.tap(find.text('复位故障源（再点重试恢复子树）'));
    await tester.pumpAndSettle();
    final bool finalNormal = find.text('子树运行正常').evaluate().isNotEmpty;
    final bool finalOuter = find.text('边界外的这行字始终可读：局部崩、全局活').evaluate().isNotEmpty;
    await step('step7-再复位-回到完整', '子树正常=${finalNormal ? '可见' : '缺失'},边界外文字=${finalOuter ? '可见' : '缺失'}', '子树正常=可见,边界外文字=可见');

    lines.add('RECEIPT_END|17_5_crash');
    await writeReceipt(tester, '17_5_crash.txt', lines);
  });
}
