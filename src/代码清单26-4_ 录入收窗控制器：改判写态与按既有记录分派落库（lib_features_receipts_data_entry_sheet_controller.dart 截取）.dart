// ……（节略：文件头注释、import 与 Loading/Error 两态，见仓内原文）
class DataEntrySheetLoaded extends DataEntrySheetState {
  // ……（节略：构造器与其余字段，见仓内原文）

  /// verdict null = 未判定（空选择器值）。
  final String? verdict;

  // ……（节略：既有记录查询与 copyWith，见仓内原文）
}

// ……（节略：DataEntrySheetSaving 状态类，见仓内原文）

class DataEntrySheetController extends Notifier<DataEntrySheetState> {
  // ……（节略：receiptId 字段、三个 API 字段与 build 初始化，见仓内原文）

  // ……（节略：load 与两个键切换入口 selectSample/selectParameter，见仓内原文）

  /// 键切换共用回填：既有记录在 → 表单值全量回填；新键 → 清空（未判定）。
  DataEntrySheetLoaded _fillFromExisting(DataEntrySheetLoaded s) {
    final existing = s.currentRecord;
    return s.copyWith(
      result: existing?.result ?? '',
      requirement: existing?.requirement ?? '',
      standardCode: existing?.standardCode ?? '',
      clearVerdict: existing == null,
      verdict: existing?.verdict,
      clearFormError: true,
    );
  }

  // ……（节略：selectSample/selectParameter 两个键切换入口，见仓内原文）

  void updateForm({
    String? result,
    String? requirement,
    String? standardCode,
    String? verdict,
    bool clearVerdict = false,
  }) {
    final cur = state;
    if (cur is! DataEntrySheetLoaded || cur is DataEntrySheetSaving) return;
    state = cur.copyWith(
      result: result,
      requirement: requirement,
      standardCode: standardCode,
      verdict: verdict,
      clearVerdict: clearVerdict,
      clearFormError: true,
    );
  }

  /// 保存（I02/I03，AC-3/4/5）：create-vs-update 按当前键既有记录；必填缺失
  /// fail-fast 不发请求；成功返回 true（页侧收窗 + SnackBar + 队列回刷），
  /// 失败留窗保输入。standardCode 空串归一不传；verdict 随 body（null=未判定）。
  Future<bool> save() async {
    final cur = state;
    if (cur is! DataEntrySheetLoaded || cur is DataEntrySheetSaving) {
      return false;
    }
    final result = cur.result.trim();
    final requirement = cur.requirement.trim();
    if (result.isEmpty || requirement.isEmpty) {
      state = cur.copyWith(formError: '请完整填写检测结果与技术要求');
      return false;
    }
    final standardCode = cur.standardCode.trim().isEmpty
        ? null
        : cur.standardCode.trim();
    final existing = cur.currentRecord;
    state = DataEntrySheetSaving(cur);
    try {
      final TestRecord saved;
      if (existing != null) {
        final response = await _recordsApi.testRecordsUpdateTestRecord(
          id: existing.id,
          updateTestRecordRequest: UpdateTestRecordRequest(
            (b) => b
              ..sampleId = cur.selectedSampleId
              ..parameterCode = cur.selectedParameterCode
              ..standardCode = standardCode
              ..requirement = requirement
              ..result = result
              ..verdict = cur.verdict,
          ),
        );
        saved = response.data!;
      } else {
        final response = await _recordsApi.testRecordsCreateTestRecord(
          createTestRecordRequest: CreateTestRecordRequest(
            (b) => b
              ..sampleId = cur.selectedSampleId
              ..parameterCode = cur.selectedParameterCode
              ..standardCode = standardCode
              ..requirement = requirement
              ..result = result
              ..verdict = cur.verdict,
          ),
        );
        saved = response.data!;
      }
      if (!ref.mounted) return false;
      // 成功即返：页侧凭 true 收窗 + SnackBar + 队列 silent 回刷。
      state = cur.copyWith(formError: null, result: saved.result);
      return true;
    } on DioException catch (e) {
      if (!ref.mounted) return false;
      state = cur.copyWith(
        formError: e.response == null ? '无法连接服务器' : '保存失败，请重试',
      );
      return false;
    }
  }
}

// ……（节略：文件尾 autoDispose family provider 声明，见仓内原文）