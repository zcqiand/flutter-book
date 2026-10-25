// ===== 过滤值打包与触发 =====
  // 三过滤值留页侧（I-1，spec §3）：文本未提交不算过滤，提交/下拉改动才
  // 触发 load；刷新从同一来源取参，保证「所见即所刷」。
  final _keywordCtrl = TextEditingController();
  final _contractIdCtrl = TextEditingController();
  FlowStatus? _flowStatus;

  ({String? contractId, FlowStatus? flowStatus, String? keyword})
  get _filters => (
    contractId: _contractIdCtrl.text.trim().isEmpty
        ? null
        : _contractIdCtrl.text.trim(),
    flowStatus: _flowStatus,
    keyword: _keywordCtrl.text.trim().isEmpty ? null : _keywordCtrl.text.trim(),
  );

  void _applyFilters() {
    final f = _filters;
    ref
        .read(receiptListControllerProvider.notifier)
        .load(
          contractId: f.contractId,
          flowStatus: f.flowStatus,
          keyword: f.keyword,
        );
  }

  /// 下拉刷新（保过滤器，终审 T5a 收口）：以过滤区当前值 silent 刷新，
  /// 不闪 Loading（T2a）。
  Future<void> _refresh() {
    final f = _filters;
    return ref
        .read(receiptListControllerProvider.notifier)
        .load(
          contractId: f.contractId,
          flowStatus: f.flowStatus,
          keyword: f.keyword,
          silent: true,
        );
  }

// ===== 过滤区与四态渲染 =====
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordCtrl,
                    decoration: const InputDecoration(
                      labelText: '关键词',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _contractIdCtrl,
                    decoration: const InputDecoration(
                      labelText: '合同 ID',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DropdownButtonFormField<FlowStatus?>(
                // ……（节略：value 废弃注记两行，见仓内原文）
                initialValue: _flowStatus,
                decoration: const InputDecoration(
                  labelText: '环节',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<FlowStatus?>(
                    value: null,
                    child: Text('全部'),
                  ),
                  // FlowStatus 是 EnumClass：values 是 BuiltSet 非 List（G-12
                  // 全 8 值，标签复用 flowStatusLabel，漏值测试先红）。
                  for (final s in FlowStatus.values)
                    DropdownMenuItem<FlowStatus?>(
                      value: s,
                      child: Text(flowStatusLabel(s)),
                    ),
                ],
                onChanged: (v) {
                  setState(() => _flowStatus = v);
                  _applyFilters();
                },
              ),
            ),
          ),
          Expanded(
            child: switch (listState) {
              ReceiptListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              ReceiptListEmpty() => const Center(child: Text('暂无接样单')),
              ReceiptListError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _applyFilters,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
              ReceiptListLoaded(:final items) => RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  // T3b：列表短于视口（演示数据常态）也能拉动触发下拉刷新。
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final r = items[i];
                    return ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ReceiptDetailPage(receiptId: r.id),
                        ),
                      ),
                      title: Text(
                        '${r.commissionCode}（${r.projectName ?? '未填项目名'}）',
                      ),
                      subtitle: Text(
                        '${r.categoryCode} · ${flowStatusLabel(r.flowStatus)} · ${r.receivedBy}',
                      ),
                      trailing: Text(r.commissionDate),
                    );
                  },
                  separatorBuilder: (_, _) => const Divider(height: 1),
                ),
              ),
            },
          ),
        ],
      ),