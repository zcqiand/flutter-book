// ===== lib/features/receipts/receipt_detail_page.dart =====
  /// 删除确认弹窗（M03.F01.I03）：文案必须明示 CASCADE（同时删下属样品）。
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除接样单'),
        content: const Text('删除后不可恢复，将同时删除下属样品。确定删除？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(receiptDetailControllerProvider.notifier).delete();
    }
  }

// ===== lib/features/receipts/receipt_detail_controller.dart =====
  bool _deleting = false;

  /// 删除接样单（M03.F01.I03）。防重入：删除进行期再点 = no-op；
  /// 成功 → [ReceiptDetailDeleted]；失败 → [ReceiptDetailError]（G-10）。
  Future<void> delete() async {
    final id = _currentId;
    if (id == null || _deleting) return;
    _deleting = true;
    try {
      await _receiptsApi.receiptsDeleteReceipt(id: id);
      if (!ref.mounted) return; // autoDispose：页面 pop 后丢陈旧响应
      state = const ReceiptDetailDeleted();
    } on DioException catch (e) {
      if (!ref.mounted) return;
      state = ReceiptDetailError(_mapError(e));
    } finally {
      _deleting = false;
    }
  }