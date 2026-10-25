// ===== lib/features/receipts/receipt_list_controller.dart =====
/// 列表状态机（G-10 三分错误形态）。
sealed class ReceiptListState {
  const ReceiptListState();
}

class ReceiptListLoading extends ReceiptListState {
  const ReceiptListLoading();
}

class ReceiptListLoaded extends ReceiptListState {
  const ReceiptListLoaded({
    required this.items,
    this.contractId,
    this.flowStatus,
    this.keyword,
  });
  final BuiltList<SampleReceipt> items;
  final String? contractId;
  final FlowStatus? flowStatus;
  final String? keyword;
}

class ReceiptListEmpty extends ReceiptListState {
  const ReceiptListEmpty({this.contractId, this.flowStatus, this.keyword});
  final String? contractId;
  final FlowStatus? flowStatus;
  final String? keyword;
}

class ReceiptListError extends ReceiptListState {
  const ReceiptListError({required this.message});
  final String message;
}

// ……（节略）

class ReceiptListController extends Notifier<ReceiptListState> {
  late final ReceiptsApi _api;

  @override
  ReceiptListState build() {
    _api = ref.watch(receiptsApiProvider);
    return const ReceiptListLoading();
  }

  /// silent=true 不闪 loading（下拉刷新复用）。
  /// 醒来先查 ref.mounted，陈旧响应丢弃不写 state（riverpod UnmountedRefException）。
  Future<void> load({
    String? contractId,
    FlowStatus? flowStatus,
    String? keyword,
    bool silent = false,
  }) async {
    if (!silent) state = const ReceiptListLoading();
    try {
      final response = await _api.receiptsListReceipts(
        contractId: contractId,
        flowStatus: flowStatus,
        keyword: keyword,
      );
      if (!ref.mounted) return;
      final items = response.data?.items ?? BuiltList<SampleReceipt>();
      if (items.isEmpty) {
        state = ReceiptListEmpty(
          contractId: contractId,
          flowStatus: flowStatus,
          keyword: keyword,
        );
      } else {
        state = ReceiptListLoaded(
          items: items,
          contractId: contractId,
          flowStatus: flowStatus,
          keyword: keyword,
        );
      }
    } on DioException catch (e) {
      if (!ref.mounted) return;
      state = ReceiptListError(message: _mapError(e));
    }
  }

  String _mapError(DioException e) {
    if (e.response == null) return '无法连接服务器';
    return '加载失败，请重试';
  }
}

final receiptListControllerProvider =
    NotifierProvider.autoDispose<ReceiptListController, ReceiptListState>(
      ReceiptListController.new,
    );

// ===== lib/features/receipts/receipts_list_page.dart =====
/// 接样单列表（M03.F01.I01）。
class ReceiptsListPage extends ConsumerStatefulWidget {
  const ReceiptsListPage({super.key});

  @override
  ConsumerState<ReceiptsListPage> createState() => _ReceiptsListPageState();
}

class _ReceiptsListPageState extends ConsumerState<ReceiptsListPage> {
  // 三过滤值留页侧（I-1，spec §3）：文本未提交不算过滤，提交/下拉改动才
  // 触发 load；刷新从同一来源取参，保证「所见即所刷」。
  final _keywordCtrl = TextEditingController();
  final _contractIdCtrl = TextEditingController();
  FlowStatus? _flowStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(receiptListControllerProvider.notifier).load(),
    );
  }

// ……（节略）

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(receiptListControllerProvider);
    return Scaffold(

// ……（节略）

          IconButton(
            tooltip: '登出',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),