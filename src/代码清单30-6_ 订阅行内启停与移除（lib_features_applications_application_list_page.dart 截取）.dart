  /// 行内启停（M00.F05.I03）：body 恰 status（expireTime 不随），
  /// 成功后以 PUT 响应原位替换该行（后端回包即权威状态）。
  Future<void> _toggle(TenantApplication app) async {
    final ok = await _controller.setStatus(app, app.status == 1 ? 2 : 1);
    if (!mounted) return;
    if (!ok) _toast('操作失败，请重试');
  }

  /// 移除订阅（M00.F05.I04）：确认文案明示只解绑、不删除应用本体。
  Future<void> _remove(TenantApplication app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('移除订阅'),
        content: Text(
          '确认移除订阅「${app.clientId}」？仅解除本租户与该应用的绑定，'
          '不删除应用本体。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(tenantApplicationsApiProvider)
          .tenantApplicationsRemoveTenantApplication(
            tenantId: widget.tenantId,
            clientId: app.clientId,
          );
      await _controller.load(silent: true);
      if (!mounted) return;
      _toast('已移除订阅');
    } on DioException {
      if (!mounted) return;
      _toast('操作失败，请重试');
    }
  }