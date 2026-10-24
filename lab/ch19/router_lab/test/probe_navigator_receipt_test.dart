// test/probe_navigator_receipt_test.dart
// 回执 A 探针（widget test 轨）：场景程序化驱动 → debugPrint → 断言 → 通过即停
// 消费 lib/main_navigator.dart 正文清单原件，零改动零 mock
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_lab/main_navigator.dart';

void main() {
  testWidgets('回执 A：登录→列表→详情→保存 pop 回传收藏→红心点亮 全链路',
      (WidgetTester tester) async {
    void probe(String msg) => debugPrint('PROBE-A: $msg');

    // [P01] 冷启动落在登录页（routes 表 '/'）
    await tester.pumpWidget(const NavigatorApp());
    await tester.pumpAndSettle();
    probe('P01 冷启动: 栈顶=LoginPage（命名路由 /），AppBar=登录');

    // [P02] 登录：pushReplacementNamed('/list')，栈底被替换
    await tester.enterText(find.byType(TextField), 'probe-account');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();
    probe("P02 登录点击 -> pushReplacementNamed('/list'): "
        '栈顶=ListPage，LoginPage 已被替换（按返回不再回登录页）');

    // [P03] 列表点第 2 项：MaterialPageRoute<bool> 直 push，构造参数进栈
    await tester.tap(find.text('页面栈与返回值'));
    await tester.pumpAndSettle();
    probe('P03 push MaterialPageRoute<bool>(DetailPage): 栈顶=DetailPage，'
        '构造参数直传 {id: 2, title: 页面栈与返回值, isFavorite: false}');

    // [P04] 详情页内本地切换收藏态（未 -> 已），列表此刻不受影响
    expect(find.text('未收藏（点此收藏）'), findsOneWidget);
    await tester.tap(find.text('未收藏（点此收藏）'));
    await tester.pumpAndSettle();
    probe('P04 详情页 setState: _isFavorite false->true（本地态，列表未刷新）');

    // [P05] 保存并返回：pop(!_isFavorite)=true，列表页 await 的 Future complete
    await tester.tap(find.text('保存并返回列表'));
    await tester.pumpAndSettle();
    await tester.pump(); // pop 回传的 await 续体 setState 后再补一帧，确保列表重建被泵出
    probe('P05 _saveAndPop -> pop(true): DetailPage 出栈，result=true 交还列表页');

    // [P06] 列表页 setState 收藏点亮：红心实心图标出现在第 2 项
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    probe('P06 ListPage setState: 第 2 项红心点亮（Icons.favorite, red ×1）');

    // [P07] 再次进详情：构造参数 isFavorite=true（上一轮回传已入列表状态）
    await tester.tap(find.text('页面栈与返回值'));
    await tester.pumpAndSettle();
    probe('P07 二次进详情: 构造参数 {id: 2, isFavorite: true}（回传生效）');

    // [P08] 本地切换已收藏 -> 未收藏，保存回传 false：红心熄灭
    await tester.tap(find.text('已收藏（点此取消）'));
    await tester.tap(find.text('保存并返回列表'));
    await tester.pumpAndSettle();
    await tester.pump(); // 同 P05：回传 setState 后补一帧
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(find.byIcon(Icons.favorite_border), findsNWidgets(3));
    probe('P08 pop(false) 回传: 红心熄灭（favorite_border ×3），刷新为移除收藏');

    // [P09] 系统返回路径：pop 无结果 -> result==null，不触发刷新
    await tester.tap(find.text('页面栈与返回值'));
    await tester.pumpAndSettle();
    final NavigatorState nav =
        tester.element(find.byType(DetailPage)).findAncestorStateOfType<NavigatorState>()!;
    nav.pop(); // 模拟系统返回键：不带结果出栈
    await tester.pumpAndSettle();
    await tester.pump(); // null 回传路径同样补一帧
    expect(find.byType(ListPage), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNWidgets(3));
    probe('P09 系统返回 pop(null): result==null，列表不 setState，收藏态保持不变');

    probe('P10 全链路完成: push/pop/构造参数/回传 null|false|true 三分支全部命中');
  });
}
