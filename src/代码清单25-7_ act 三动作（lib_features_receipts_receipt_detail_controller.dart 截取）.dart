  // ……（节略：操作人身份注记两行，见仓内原文）
  String? operatorName;

  bool _acting = false;

  /// act 三动作（M03.F01.I04 提交 / I08 三动作）。进行期再调 = no-op（防抖）。
  /// 成功 → `load` 重载（新 flowStatus + history 增量）；422（RETURN 无前置）→
  /// 专文案「当前阶段不可退回」；其余 DioException → G-10 三分支。
  Future<void> act(FlowAction action) async {
    final id = _currentId;
    if (id == null || _acting) return;
    _acting = true;
    try {
      await _receiptsApi.receiptsActFlowReceiving(
        flowActionRequest: FlowActionRequest(
          (b) => b
            ..ids = ListBuilder<String>([id])
            ..action = action
            ..operator_ = operatorName!,
        ),
      );
      await load(id: id); // 新 flowStatus + history 增量
    } on DioException catch (e) {
      // ……（节略：死代码更正注记两行，见仓内原文）
      if (!ref.mounted) return; // autoDispose：页面 pop 后丢陈旧响应
      if (e.response?.statusCode == 422) {
        state = ReceiptDetailError('当前阶段不可退回');
      } else {
        state = ReceiptDetailError(_mapError(e));
      }
    } finally {
      _acting = false;
    }
  }