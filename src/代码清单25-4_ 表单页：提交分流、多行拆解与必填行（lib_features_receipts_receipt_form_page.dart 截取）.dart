// ===== 提交分流：existing 分 Create/Update 两路 =====
  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final e = widget.existing;
    if (e == null) {
      ref
          .read(receiptFormControllerProvider.notifier)
          .submitCreate(
            CreateSampleReceiptRequest(
              (b) => b
                ..contractId = _contractId.text.trim()
                ..commissionCode = _commissionCode.text.trim()
                ..commissionDate = _commissionDate.text.trim()
                ..categoryCode = _categoryCode.text.trim()
                ..receivedBy = _receivedBy.text.trim()
                ..sampleSource = _sampleSource.text.trim()
                ..testCategory = _testCategory.text.trim()
                ..judgmentBasis = _lines(_judgmentBasis.text)
                ..testingBasis = _lines(_testingBasis.text)
                ..testParameters = _lines(_testParameters.text),
            ),
          );
    } else {
      ref
          .read(receiptFormControllerProvider.notifier)
          .submitUpdate(
            id: e.id,
            req: UpdateSampleReceiptRequest(
              (b) => b
                ..contractId = _contractId.text.trim()
                ..commissionCode = _commissionCode.text.trim()
                ..commissionDate = _commissionDate.text.trim()
                ..categoryCode = _categoryCode.text.trim()
                ..receivedBy = _receivedBy.text.trim()
                ..sampleSource = _sampleSource.text.trim()
                ..testCategory = _testCategory.text.trim()
                ..judgmentBasis = _lines(_judgmentBasis.text)
                ..testingBasis = _lines(_testingBasis.text)
                ..testParameters = _lines(_testParameters.text),
            ),
          );
    }
  }

  // ……（节略：_lines 实现注记四行，见仓内原文）
  ListBuilder<String> _lines(String text) => ListBuilder<String>(
    text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty),
  );

// ===== 成功与失败监听 =====
    ref.listen<ReceiptFormState>(receiptFormControllerProvider, (prev, next) {
      if (next is ReceiptFormSuccess) {
        // 成功后回列表：保活过滤器原样带回，silent 刷新不闪 loading。
        final s = ref.read(receiptListControllerProvider);
        final notifier = ref.read(receiptListControllerProvider.notifier);
        if (s is ReceiptListLoaded) {
          notifier.load(
            contractId: s.contractId,
            flowStatus: s.flowStatus,
            keyword: s.keyword,
            silent: true,
          );
        } else {
          notifier.load(silent: true);
        }
        Navigator.of(context).pop();
      }
      if (next is ReceiptFormError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

// ===== 必填行帮助方法 =====
  Widget _req(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        validator: (v) => (v == null || v.trim().isEmpty) ? '必填' : null,
      ),
    );
  }