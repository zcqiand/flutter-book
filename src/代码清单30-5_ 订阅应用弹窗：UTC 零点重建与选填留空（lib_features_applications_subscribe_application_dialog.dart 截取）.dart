// @entry M00.F05.I02
// ……（节略：imports 与字段控制器）

/// 订阅应用弹窗（M00.F05.I02）：契约 `SubscribeTenantApplicationRequest`
/// 恰 clientId 必填 + expireTime 可选（yyyy-MM-dd，留空不随 body——选填
/// 留空不随请求，禁空串兜底 ADR-0019 同源纪律）。
class SubscribeApplicationDialog extends ConsumerStatefulWidget {
// ……（节略：字段控制器与生命周期）

  Future<void> _save() async {
    if (_saving) return;
    if (_clientCtrl.text.trim().isEmpty) {
      setState(() => _error = '请填写客户端标识');
      return;
    }
    // 到期时间选填：填了必须是 yyyy-MM-dd 可解析。Iso8601DateTimeSerializer
    // 只收 UTC——按日期分量重建 UTC 零点（本地解析实例序列化即炸）。
    DateTime? expire;
    final expireText = _expireCtrl.text.trim();
    if (expireText.isNotEmpty) {
      final parsed = DateTime.tryParse(expireText);
      if (parsed == null) {
        setState(() => _error = '到期时间格式应为 yyyy-MM-dd');
        return;
      }
      expire = DateTime.utc(parsed.year, parsed.month, parsed.day);
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(tenantApplicationsApiProvider)
          .tenantApplicationsSubscribeTenantApplication(
            tenantId: widget.tenantId,
            subscribeTenantApplicationRequest:
                SubscribeTenantApplicationRequest(
                  (b) => b
                    ..clientId = _clientCtrl.text.trim()
                    ..expireTime = expire,
                ),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true); // 页侧凭 true 出 SnackBar + 回刷
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.response == null ? '无法连接服务器' : '保存失败，请重试';
      });
    }
  }

// ……（节略：表单骨架，到期时间 helper 文案「yyyy-MM-dd，选填」）
}