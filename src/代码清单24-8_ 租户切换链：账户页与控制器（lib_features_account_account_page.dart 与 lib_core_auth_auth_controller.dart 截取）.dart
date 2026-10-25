// ===== lib/features/account/account_page.dart =====
          Text('关联租户', style: Theme.of(context).textTheme.titleSmall),
          ...s.tenants.map((t) {
            final current = t.tenantId == s.currentTenantId;
            return ListTile(
              leading: const Icon(Icons.business_outlined),
              title: Text(t.name),
              subtitle: Text(t.code),
              trailing: current
                  ? const Chip(label: Text('当前'))
                  : _switchingId == t.tenantId
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: () => _switch(t),
                      child: const Text('切换'),
                    ),
            );
          }),

// ……（节略）

  /// 切换（M00.F02.I01）：成功后 invalidate 接样列表（autoDispose 重建，
  /// ReceiptsListPage 挂着监听原地更新）+ 会话重取；失败不动 store。
  Future<void> _switch(MyTenant t) async {
    final scaffold = ScaffoldMessenger.of(context);
    setState(() => _switchingId = t.tenantId);
    final ok = await ref
        .read(authControllerProvider.notifier)
        .switchTenant(t.tenantId);
    if (!mounted) return;
    if (!ok) {
      setState(() => _switchingId = null);
      scaffold.showSnackBar(const SnackBar(content: Text('切换失败，请重试')));
      return;
    }
    // 整表刷新：接样列表 load() 在新 token 数据域重拉（shell 页常挂监听，
    // 已弃用 notifier 而同步抛，_switch 后续全断）。
    ref.read(receiptListControllerProvider.notifier).load();
    await _load();
    if (!mounted) return;
    setState(() => _switchingId = null);
    scaffold.showSnackBar(SnackBar(content: Text('已切换到 ${t.name}')));
  }

// ===== lib/core/auth/auth_controller.dart =====
  /// 租户切换（REQ-2026-011 M00.F02.I01）：POST /auth/switch-tenant 换发
  /// token 对落 store（保持 Authed 不回登录页）；失败 return false 不动
  /// store。会话面（currentTenantId）由账户页重取 /auth/me。
  Future<bool> switchTenant(String tenantId) async {
    try {
      final resp = await _api.authSwitchTenant(
        switchTenantRequest: SwitchTenantRequest((b) => b..tenantId = tenantId),
      );
      final body = resp.data;
      final access = body?.token;
      if (body == null || access == null || access.isEmpty) return false;
      await _store.save(
        accessToken: access,
        refreshToken: body.refreshToken, // 契约可选，可空直存（login 同纪律）
      );
      return true;
    } on Exception {
      return false;
    }
  }