  testWidgets('详情字段表 + 样品区渲染（// fn: M03.F09.I01）', (tester) async {
    // fn: M03.F09.I01
    final dio = Dio();
    await pumpDetail(tester, dio);
    await tester.pumpAndSettle();
    expect(find.text('WT-2026-001'), findsOneWidget);
    expect(find.text('示例工程'), findsOneWidget);
    expect(find.text('—'), findsWidgets); // 缺席字段显示 —
    expect(find.text('S-001'), findsOneWidget); // 样品区
  });