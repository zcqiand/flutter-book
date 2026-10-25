sealed class ReceiptFormState {
  // ……（节略：const 基构造注记一行，见仓内原文）
}

class ReceiptFormIdle extends ReceiptFormState {
  const ReceiptFormIdle();
}

class ReceiptFormSubmitting extends ReceiptFormState {
  const ReceiptFormSubmitting();
}

class ReceiptFormSuccess extends ReceiptFormState {
  const ReceiptFormSuccess(this.receipt);
  final SampleReceipt receipt;
}

class ReceiptFormError extends ReceiptFormState {
  const ReceiptFormError(this.message);
  final String message;
}

class ReceiptFormController extends Notifier<ReceiptFormState> {
  late final ReceiptsApi _api;

  // ……（节略：防抖与 mounted 纪律注记，见仓内原文）
  Future<void> submitCreate(CreateSampleReceiptRequest req) async {
    if (state is ReceiptFormSubmitting) return;
    state = const ReceiptFormSubmitting();
    try {
      final resp = await _api.receiptsCreateReceipt(
        createSampleReceiptRequest: req,
      );
      if (!ref.mounted) return;
      state = ReceiptFormSuccess(resp.data!);
    } on DioException catch (e) {
      if (!ref.mounted) return;
      state = ReceiptFormError(_mapError(e));
    }
  }

  // ……（节略：T5b 更正注记三行，见仓内原文）
  Future<void> submitUpdate({
    required String id,
    required UpdateSampleReceiptRequest req,
  }) async {
    if (state is ReceiptFormSubmitting) return;
    state = const ReceiptFormSubmitting();
    try {
      final resp = await _api.receiptsUpdateReceipt(
        id: id,
        updateSampleReceiptRequest: req,
      );
      if (!ref.mounted) return;
      state = ReceiptFormSuccess(resp.data!);
    } on DioException catch (e) {
      if (!ref.mounted) return;
      state = ReceiptFormError(_mapError(e));
    }
  }

  String _mapError(DioException e) {
    if (e.response == null) return '无法连接服务器';
    if (e.response!.statusCode == 422) return '保存失败：数据未通过校验';
    return '保存失败，请重试'; // T5c：本页只有保存动作，报「保存」不报「加载」
  }
}

// ……（节略：provider 声明与 autoDispose 注记，见仓内原文）