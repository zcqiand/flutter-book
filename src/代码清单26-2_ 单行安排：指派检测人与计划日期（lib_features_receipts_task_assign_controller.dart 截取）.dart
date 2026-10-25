/// 任务安排状态机（M03.F02.I02）。assigneeId 不传（后端三字段 None-跳过
/// patch 语义：传 id 无消费面；取消分配家族规划中，见 REQ-2026-004）。
sealed class TaskAssignState {
  // ……（节略：Idle/Saving/Error 三态 const 定义，见仓内原文）
}

class TaskAssignSaved extends TaskAssignState {
  const TaskAssignSaved({required this.receipt});
  final SampleReceipt receipt;
}

class TaskAssignController extends Notifier<TaskAssignState> {
  // ……（节略：_api 字段与 build 初始化，见仓内原文）

  /// saving 期再调是 no-op（双提交防抖，Review Focus 5）。
  /// state=Saving 在首个 await 前同步置位，同帧二次调用必被拦。
  Future<void> assign({
    required String receiptId,
    required String assigneeName,
    required String plannedTestDate,
  }) async {
    if (state is TaskAssignSaving) return;
    state = const TaskAssignSaving();
    try {
      final request = AssignTaskRequest(
        (b) => b
          ..assigneeName = assigneeName
          ..plannedTestDate = plannedTestDate,
      );
      final response = await _api.receiptsAssignTask(
        id: receiptId,
        assignTaskRequest: request,
      );
      if (!ref.mounted) return;
      state = TaskAssignSaved(receipt: response.data!);
    } on DioException catch (e) {
      if (!ref.mounted) return;
      state = TaskAssignError(message: _mapError(e));
    }
  }

  // ……（节略：_mapError 辅助方法，见仓内原文）
}

// ……（节略：文件尾 autoDispose provider 声明，见仓内原文）