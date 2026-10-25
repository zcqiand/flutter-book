  testWidgets('receiving 阶段三按钮齐全（// fn: M03.F01.I08）', (tester) async {
    // fn: M03.F01.I08
    await pumpDetail(tester);
    await tester.pumpAndSettle();
    expect(find.text('提交'), findsOneWidget);
    expect(find.text('退回'), findsOneWidget);
    expect(find.text('撤回'), findsOneWidget);
  });

  testWidgets('提交成功 → act 上发 + 详情重载（// fn: M03.F01.I04）', (tester) async {
    // fn: M03.F01.I04
    await pumpDetail(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();
    expect(actCalls, 1);
    expect(actBody!.ids, ['r-1']);
    expect(actBody!.action, FlowAction.submit);
    expect(actBody!.operator_, '测试用户'); // displayName 非空优先
    expect(detailCalls, 2); // 初次 + act 后重载
  });