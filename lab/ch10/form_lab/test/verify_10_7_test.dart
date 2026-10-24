// 验证环境探针（不入书）：清单 10-6/10-7 两页复用验证。
// 同一套组件（LabeledField/SubmitBar）在注册页与收货地址页行为一致，差异只在参数。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_lab/form_widgets.dart';
import 'package:form_lab/main.dart';

Future<void> _goto(WidgetTester tester, String buttonText) async {
  await tester.pumpWidget(const FormLabApp());
  await tester.pump();
  await tester.tap(find.text(buttonText));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('两页共用同一组件类型：注册页 2 行、地址页 3 行', (tester) async {
    await _goto(tester, '去注册页');
    expect(find.byType(LabeledField), findsNWidgets(2));
    expect(find.byType(SubmitBar), findsOneWidget);
    // 注册页参数面：label 邮箱/密码，提交文案「注册」
    expect(find.text('邮箱'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
    expect(find.text('注册'), findsWidgets); // AppBar+按钮同名

    // 返回首页，进地址页：同一 byType 命中，行数与 label 不同=参数差异
    await tester.pageBack();
    await tester.pumpAndSettle();
    await _goto(tester, '去收货地址页');
    expect(find.byType(LabeledField), findsNWidgets(3));
    expect(find.byType(SubmitBar), findsOneWidget);
    expect(find.text('收货人'), findsOneWidget);
    expect(find.text('联系电话'), findsOneWidget);
    expect(find.text('详细地址'), findsOneWidget);
    expect(find.text('保存地址'), findsOneWidget);
  });

  testWidgets('注册页两道闸：邮箱校验拦截、onChanged 实抓回执', (tester) async {
    await _goto(tester, '去注册页');
    // 空邮箱直接提交 → 邮箱 validator 拦截
    await tester.tap(find.byType(SubmitBar));
    await tester.pump();
    expect(find.text('邮箱需包含 @'), findsOneWidget);

    // onChanged 回调逐字回执
    await expectLater(() async {
      await tester.enterText(
          find.byType(TextFormField).at(0), 'a@b.com');
      await tester.pump();
    }, prints(contains('邮箱输入：a')));
  });

  testWidgets('patch-02 复验：密码闸已翻正——123 短密码拦截出红字、提交回调不执行',
      (tester) async {
    await _goto(tester, '去注册页');
    await tester.enterText(
        find.byType(TextFormField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.pump();
    // 修正后口径与清单 10-1 一致：length<6 报「密码至少 6 位」并拦截
    // 10-7 无 autovalidateMode（回调档）：红字由 tap 提交触发
    await tester.tap(find.byType(SubmitBar));
    await tester.pump();
    expect(find.text('密码至少 6 位'), findsOneWidget);
    // 拦截生效：再次提交仍无「注册提交」打印
    await expectLater(() async {
      await tester.tap(find.byType(SubmitBar));
      await tester.pump();
    }, prints(isNot(contains('注册提交：'))));

    // 反向：8 位密码放行并出提交打印（修正后行为）
    await tester.enterText(
        find.byType(TextFormField).at(1), '12345678');
    await tester.pump();
    await tester.tap(find.byType(SubmitBar));
    await tester.pump();
    expect(find.text('密码至少 6 位'), findsNothing);
    await expectLater(() async {
      await tester.tap(find.byType(SubmitBar));
      await tester.pump();
    }, prints(contains('注册提交：a@b.com')));
  });

  testWidgets('patch-02 复验：收货人闸已翻正——留空拦截出红字、提交回调不执行',
      (tester) async {
    await _goto(tester, '去收货地址页');
    // 收货人留空 + 电话 11 位 + 地址达标 → 「请填写收货人」命中
    await tester.enterText(
        find.byType(TextFormField).at(1), '13800138000');
    await tester.enterText(
        find.byType(TextFormField).at(2), '某某路 1 号院');
    await tester.pump();
    await tester.tap(find.byType(SubmitBar));
    await tester.pump();
    expect(find.text('请填写收货人'), findsOneWidget);
    // 拦截生效：再次提交仍无「地址提交」打印
    await expectLater(() async {
      await tester.tap(find.byType(SubmitBar));
      await tester.pump();
    }, prints(isNot(contains('地址提交：'))));

    // 反向：填了收货人后放行并出提交打印（修正后行为）
    await tester.enterText(find.byType(TextFormField).at(0), '张三');
    await tester.pump();
    await tester.tap(find.byType(SubmitBar));
    await tester.pump();
    expect(find.text('请填写收货人'), findsNothing);
    await expectLater(() async {
      await tester.tap(find.byType(SubmitBar));
      await tester.pump();
    }, prints(contains('地址提交：张三')));
  });

  testWidgets('地址页回调档校验：手机号 11 位、地址 5 字规则如实生效', (tester) async {
    await _goto(tester, '去收货地址页');
    await tester.enterText(
        find.byType(TextFormField).at(1), '12345');
    await tester.enterText(
        find.byType(TextFormField).at(2), '短址');
    await tester.pump();
    await tester.tap(find.byType(SubmitBar));
    await tester.pump();
    expect(find.text('手机号需为 11 位'), findsOneWidget);
    expect(find.text('地址至少 5 个字'), findsOneWidget);
  });
}
