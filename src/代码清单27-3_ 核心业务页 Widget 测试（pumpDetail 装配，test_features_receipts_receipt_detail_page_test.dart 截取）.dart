  Future<void> pumpDetail(
    WidgetTester tester,
    Dio dio, {
    String receiptId = 'r-1',
  }) async {
    // 字段表 21 行 + 样品区 + 时间线总高超出默认 800x600 逻辑试面，ListView
    // 视口外子项不进树（sliver 懒装配）——拉高试面让全部区块一次进树。
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final adapter = DioAdapter(dio: dio, matcher: const UrlRequestMatcher());
    adapter.onGet(
      '/api/receipts/r-1',
      (server) => server.reply(200, receiptJson()),
    );
    adapter.onGet(
      '/api/receipts/r-1/history',
      (server) => server.reply(200, [
        historyJson(action: 'submit', at: '2026-10-01T10:00:00'),
        historyJson(
          action: 'withdraw',
          at: '2026-10-01T09:00:00',
          from: 'taskAssignment',
          to: 'receiving',
        ),
      ]),
    );
    adapter.onGet(
      '/api/samples',
      (server) => server.reply(200, samplesListJson([sampleJson()])),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dioProvider.overrideWithValue(dio)],
        child: MaterialApp(home: ReceiptDetailPage(receiptId: receiptId)),
      ),
    );