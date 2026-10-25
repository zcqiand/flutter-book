/// 任务分配队列状态机（G-10 三分错误形态，M03.F02.I01）。
/// selectedIds 放 Loaded 态内：act 成功后整体回 Loaded(空选择)，状态迁移单一。
sealed class TaskQueueState {
  const TaskQueueState();
}

class TaskQueueLoading extends TaskQueueState {
  const TaskQueueLoading();
}

class TaskQueueLoaded extends TaskQueueState {
  const TaskQueueLoaded({
    required this.items,
    required this.selectedIds,
    this.keyword,
    this.actFeedback,
  });
  final BuiltList<SampleReceipt> items;
  final BuiltSet<String> selectedIds;
  final String? keyword;

  /// act 批量反馈（sample_ext saveError 同款）：逐条失败项「id：message」或
  /// 422 专文案；null = 无。页侧 ref.listen（prev is Acting）转 SnackBar，
  /// 状态自身保持 Loaded 不翻全屏错误。回刷/重载即消费置空。
  final String? actFeedback;
}

/// act 批量进行中（I05）：继承 Loaded 保住列表与选择上屏，UI 关 act 按钮。
class TaskQueueActing extends TaskQueueLoaded {
  const TaskQueueActing({
    required super.items,
    required super.selectedIds,
    super.keyword,
    super.actFeedback,
  });
}

class TaskQueueEmpty extends TaskQueueState {
  const TaskQueueEmpty({this.keyword});
  final String? keyword;
}

class TaskQueueError extends TaskQueueState {
  const TaskQueueError({required this.message});
  final String message;
}

class TaskQueueController extends Notifier<TaskQueueState> {
  late final ReceiptsApi _api;

  @override
  TaskQueueState build() {
    _api = ref.watch(receiptsApiProvider);
    return const TaskQueueLoading();
  }

  /// 队列固定 flowStatus=taskAssignment（树 I01：流程线第二环节）。
  /// silent=true 不闪 loading（act 成功后回刷复用）。
  Future<void> load({String? keyword, bool silent = false}) async {
    if (!silent) state = const TaskQueueLoading();
    try {
      final response = await _api.receiptsListReceipts(
        flowStatus: FlowStatus.taskAssignment,
        keyword: keyword,
      );
      if (!ref.mounted) return;
      final items = response.data?.items ?? BuiltList<SampleReceipt>();
      if (items.isEmpty) {
        state = TaskQueueEmpty(keyword: keyword);
      } else {
        state = TaskQueueLoaded(
          items: items,
          selectedIds: BuiltSet<String>(),
          keyword: keyword,
        );
      }
    } on DioException catch (e) {
      if (!ref.mounted) return;
      state = TaskQueueError(message: _mapError(e));
    }
  }

  void toggleSelect(String id) {
    final cur = state;
    if (cur is! TaskQueueLoaded) return;
    final builder = cur.selectedIds.toBuilder();
    if (!builder.remove(id)) builder.add(id);
    state = TaskQueueLoaded(
      items: cur.items,
      selectedIds: builder.build(),
      keyword: cur.keyword,
      actFeedback: cur.actFeedback,
    );
  }

  /// operator 解析链（M03.F01 详情页同款）：displayName 非空优先，否则
  /// userId；双空 = 无操作人身份 → null（按钮已禁，此处再拦，ADR-0019）。
  String? _resolveOperator(AuthState auth) => switch (auth) {
    Authed(:final userId, :final displayName) =>
      (displayName?.isNotEmpty ?? false) ? displayName : userId,
    _ => null,
  };

  /// act 三动作（I05：提交到数据录入/退回接样/撤回）。acting 期再调 =
  /// no-op（防抖）。200：清选择 + silent 回刷；结果含失败项 → actFeedback
  /// 逐条「id：message」（页侧 SnackBar）。422（RETURN 无前置）→ 专文案
  /// 「当前阶段不可退回」，列表与选择不动（可重试）；其余 → G-10 三分支。
  Future<void> runAct(FlowAction action) async {
    final cur = state;
    if (cur is! TaskQueueLoaded || cur is TaskQueueActing) return;
    if (cur.selectedIds.isEmpty) return;
    final operator_ = _resolveOperator(ref.read(authControllerProvider));
    if (operator_ == null) return;
    state = TaskQueueActing(
      items: cur.items,
      selectedIds: cur.selectedIds,
      keyword: cur.keyword,
    );
    try {
      final response = await _api.receiptsActFlowAssigning(
        flowActionRequest: FlowActionRequest(
          (b) => b
            ..ids = ListBuilder<String>(cur.selectedIds)
            ..action = action
            ..operator_ = operator_,
        ),
      );
      if (!ref.mounted) return; // autoDispose：页 pop 后丢陈旧响应
      final failures = response.data!.where((r) => !r.ok).toList();
      state = TaskQueueLoaded(
        items: cur.items,
        selectedIds: BuiltSet<String>(),
        keyword: cur.keyword,
        actFeedback: failures.isEmpty
            ? null
            : failures.map((r) => '${r.id}：${r.message ?? '操作失败'}').join('；'),
      );
      await load(keyword: cur.keyword, silent: true);
    } on DioException catch (e) {
      if (!ref.mounted) return;
      state = TaskQueueLoaded(
        items: cur.items,
        selectedIds: cur.selectedIds,
        keyword: cur.keyword,
        actFeedback: e.response?.statusCode == 422 ? '当前阶段不可退回' : _mapError(e),
      );
    }
  }

  String _mapError(DioException e) {
    if (e.response == null) return '无法连接服务器';
    return '加载失败，请重试';
  }
}

/// autoDispose（receiptListControllerProvider 同口径：页级业务 provider
/// 随页 pop 即 dispose，杜绝陈旧选择跨页渗漏）。
final taskQueueControllerProvider =
    NotifierProvider.autoDispose<TaskQueueController, TaskQueueState>(
      TaskQueueController.new,
    );