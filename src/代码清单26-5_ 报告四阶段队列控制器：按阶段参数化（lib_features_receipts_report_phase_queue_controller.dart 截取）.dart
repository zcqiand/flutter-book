// ……（节略：文件头 import 五行，见仓内原文）

/// 报告阶段队列状态机（M03.F05-F08 I01/I02/I05·I07，F03 DataEntryQueue
/// 同构克隆，按阶段参数化）。selectedIds 放 Loaded 态内：act 成功后整体回
/// Loaded(空选择)，迁移单一。
sealed class ReportPhaseQueueState {
  const ReportPhaseQueueState();
}

class ReportPhaseQueueLoading extends ReportPhaseQueueState {
  const ReportPhaseQueueLoading();
}

class ReportPhaseQueueLoaded extends ReportPhaseQueueState {
  const ReportPhaseQueueLoaded({
    required this.items,
    required this.selectedIds,
    this.keyword,
    this.actFeedback,
  });
  final BuiltList<SampleReceipt> items;
  final BuiltSet<String> selectedIds;
  final String? keyword;

  /// act 批量反馈（F02/F03 同款）：422 专文案或逐条失败项「id：message」；
  /// null = 无。页侧 ref.listen（prev is Acting）转 SnackBar。
  final String? actFeedback;
}

/// act 批量进行中：继承 Loaded 保住列表与选择上屏，UI 关 act 按钮。
class ReportPhaseQueueActing extends ReportPhaseQueueLoaded {
  const ReportPhaseQueueActing({
    required super.items,
    required super.selectedIds,
    super.keyword,
    super.actFeedback,
  });
}

class ReportPhaseQueueEmpty extends ReportPhaseQueueState {
  const ReportPhaseQueueEmpty({this.keyword});
  final String? keyword;
}

class ReportPhaseQueueError extends ReportPhaseQueueState {
  const ReportPhaseQueueError({required this.message});
  final String message;
}

/// 报告阶段队列控制器（family by FlowStatus：review/approval/issuance/
/// archived 四实例；riverpod 3 family create fn 直接收 arg）。
class ReportPhaseQueueController extends Notifier<ReportPhaseQueueState> {
  ReportPhaseQueueController(this.phase);

  /// 本队列固定阶段（服务端过滤保证，树 I01）。
  final FlowStatus phase;

  late final ReceiptsApi _api;

  @override
  ReportPhaseQueueState build() {
    _api = ref.watch(receiptsApiProvider);
    return const ReportPhaseQueueLoading();
  }

  /// 队列固定 flowStatus=<阶段>。silent=true 不闪 loading（act 成功后回刷）。
  Future<void> load({String? keyword, bool silent = false}) async {
    if (!silent) state = const ReportPhaseQueueLoading();
    try {
      final response = await _api.receiptsListReceipts(
        flowStatus: phase,
        keyword: keyword,
      );
      if (!ref.mounted) return;
      final items = response.data?.items ?? BuiltList<SampleReceipt>();
      if (items.isEmpty) {
        state = ReportPhaseQueueEmpty(keyword: keyword);
      } else {
        state = ReportPhaseQueueLoaded(
          items: items,
          selectedIds: BuiltSet<String>(),
          keyword: keyword,
        );
      }
    } on DioException catch (e) {
      if (!ref.mounted) return;
      state = ReportPhaseQueueError(message: _mapError(e));
    }
  }

// ……（节略：toggleSelect 与 _resolveOperator 两个辅助方法，见仓内原文）

  /// act 三动作（树 I05·I07：submit/return/withdraw，旧 I06 退回/I07 撤回
  /// 废弃语义并入）。按阶段分派到生成物端点；acting 期再调 = no-op（防抖）。
  /// 200：清选择 + silent 回刷；结果含失败项 → actFeedback 逐条「id：message」。
  /// 422（RETURN 无前置）→ 专文案「当前阶段不可退回」，列表与选择不动。
  Future<void> runAct(FlowAction action) async {
    final cur = state;
    if (cur is! ReportPhaseQueueLoaded || cur is ReportPhaseQueueActing) {
      return;
    }
    if (cur.selectedIds.isEmpty) return;
    final operator_ = _resolveOperator(ref.read(authControllerProvider));
    if (operator_ == null) return;
    state = ReportPhaseQueueActing(
      items: cur.items,
      selectedIds: cur.selectedIds,
      keyword: cur.keyword,
    );
    try {
      final request = FlowActionRequest(
        (b) => b
          ..ids = ListBuilder<String>(cur.selectedIds)
          ..action = action
          ..operator_ = operator_,
      );
      final response = switch (phase) {
        FlowStatus.review => await _api.receiptsActFlowReview(
          flowActionRequest: request,
        ),
        FlowStatus.approval => await _api.receiptsActFlowApprove(
          flowActionRequest: request,
        ),
        FlowStatus.issuance => await _api.receiptsActFlowIssuance(
          flowActionRequest: request,
        ),
        FlowStatus.archived => await _api.receiptsActFlowArchived(
          flowActionRequest: request,
        ),
        _ => throw StateError('报告队列不支持阶段 $phase'),
      };
      if (!ref.mounted) return; // autoDispose：页 pop 后丢陈旧响应
      final failures = response.data!.where((r) => !r.ok).toList();
      state = ReportPhaseQueueLoaded(
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
      state = ReportPhaseQueueLoaded(
        items: cur.items,
        selectedIds: cur.selectedIds,
        keyword: cur.keyword,
        actFeedback: e.response?.statusCode == 422 ? '当前阶段不可退回' : _mapError(e),
      );
    }
  }

// ……（节略：_mapError 错误映射两分支，见仓内原文）
}

/// autoDispose family（F03 口径：页级业务 provider 随页 pop 即 dispose），
/// 一阶段一实例。
final reportPhaseQueueControllerProvider = NotifierProvider.autoDispose
    .family<ReportPhaseQueueController, ReportPhaseQueueState, FlowStatus>(
      ReportPhaseQueueController.new,
    );