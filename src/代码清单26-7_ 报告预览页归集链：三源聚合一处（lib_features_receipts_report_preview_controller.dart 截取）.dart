// ……（节略：文件头 import 与 Loading/Error 两态，见仓内原文）

class ReportPreviewReady extends ReportPreviewState {
  const ReportPreviewReady({
    required this.samples,
    required this.recordsBySample,
    this.gateFormFields = const <ExtFieldDef>[],
  });

  final BuiltList<Sample> samples;

  /// 逐样品归集的检测记录，键 = sample.id（契约 list 端点只支持
  /// sampleId 过滤，家族 ReportPreviewModal.recordsOfSamples 同款策略）。
  final BuiltMap<String, BuiltList<TestRecord>> recordsBySample;

  /// 补录门（M03.F01.I07 门语义复用）：非空 = 先补录不渲染预览。
  final List<ExtFieldDef> gateFormFields;
}

/// 报告预览装载（REQ-2026-016 M03.F09.I03）：samples 单次取（页大小 200
/// 镜像家族）→ 门字段计算 → 逐样品 records 归集，一气呵成；任何 await
/// 失败清整体进错误态（swift ReportPreviewViewModel 同款，不留半写）。
class ReportPreviewController extends Notifier<ReportPreviewState> {
  late final SamplesApi _samplesApi;
  late final TestRecordsApi _testRecordsApi;
  late final ReportNamesApi _reportNamesApi;

  @override
  ReportPreviewState build() {
    _samplesApi = ref.watch(samplesApiProvider);
    _testRecordsApi = ref.watch(testRecordsApiProvider);
    _reportNamesApi = ref.watch(reportNamesApiProvider);
    return const ReportPreviewLoading();
  }

// ……（节略：load 前置注释两行（autoDispose 陈旧响应纪律），见仓内原文）
  Future<void> load({
    required String receiptId,
    required String categoryCode,
  }) async {
    try {
      final samplesResp = await _samplesApi.samplesListSamples(
        page: 1,
        pageSize: 200,
        receiptId: receiptId,
      );
      if (!ref.mounted) return;
      final samples = samplesResp.data?.items ?? BuiltList<Sample>();
      // 首样品缺失（无样品）不开门：空样品直接归集（空循环）。
      final gate = samples.isEmpty
          ? const <ExtFieldDef>[]
          : await _gateFields(samples.first, categoryCode);
      if (!ref.mounted) return;
      final records = <String, BuiltList<TestRecord>>{};
      for (final s in samples) {
        final resp = await _testRecordsApi.testRecordsListTestRecords(
          page: 1,
          pageSize: 200,
          sampleId: s.id,
        );
        if (!ref.mounted) return;
        records[s.id] = resp.data?.items ?? BuiltList<TestRecord>();
      }
      if (!ref.mounted) return;
      state = ReportPreviewReady(
        samples: samples,
        recordsBySample: BuiltMap<String, BuiltList<TestRecord>>(records),
        gateFormFields: gate,
      );
    } on Exception {
      if (!ref.mounted) return;
      state = const ReportPreviewError('预览失败，请重试');
    }
  }

  /// 门字段：reportNames 按 categoryCode 取 extFields（source=receipt 滤
  /// 掉，null 保留，SampleExtController.load 同构），首样品 ext 缺 key
  /// （值空也算缺）出补录清单；类别无定义 = 无门（预览照常）。
  Future<List<ExtFieldDef>> _gateFields(
    Sample first,
    String categoryCode,
  ) async {
    final resp = await _reportNamesApi.reportNamesListReportNames(
      page: 1,
      pageSize: 200,
    );
    final names = resp.data?.items ?? BuiltList<InspectionReportName>();
    InspectionReportName? matched;
    for (final n in names) {
      if (n.code == categoryCode) {
        matched = n;
        break;
      }
    }
    if (matched == null) return const <ExtFieldDef>[];
    final usable =
        matched.extFields
            ?.where((d) => d.source_ != ExtFieldDefSource.receipt)
            .toList() ??
        const <ExtFieldDef>[];
    return usable.where((d) => (first.ext[d.key] ?? '').isEmpty).toList();
  }
}

// ……（节略：文件尾 autoDispose provider 声明三行，见仓内原文）