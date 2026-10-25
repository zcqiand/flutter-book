// @entry M04.F01.I02
// ……（节略：imports 与字段控制器）

/// 应用表单弹窗（REQ-2026-010）：I02 创建 / I04 编辑双态复用。
/// 契约必填五件里 clientSecret 表单侧自动生成（sec- 前缀随机，nextjs
/// 同款，不收用户输入）；grantTypes 固定默认 authorization_code,
/// client_credentials（创建侧）；scopes 逗号串选填。编辑只提交
/// clientName/redirectUris/scopes（生成物 UpdateOAuthClientRequest 面内，
/// status 启停走 F02.I01 独立端点不混提）。
class ClientFormDialog extends ConsumerStatefulWidget {
  const ClientFormDialog({super.key, this.existing});

  final OAuthClient? existing;

// ……（节略：双态标志与字段回填）

  Future<void> _save() async {
    final name = _name.text.trim();
    final controller = ref.read(clientListControllerProvider.notifier);
    if (_isEdit) {
      setState(() => _saving = true);
      final ok = await controller.update(
        widget.existing!.clientId,
        UpdateOAuthClientRequest(
          (b) => b
            ..clientName = name
            ..redirectUris = _redirectUris.text.trim()
            ..scopes = _scopes.text.trim(),
        ),
      );
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _saving = false;
          _error = '保存失败，请重试';
        });
      }
      return;
    }
    final clientId = _clientId.text.trim();
    if (clientId.isEmpty) {
      setState(() => _error = '请填写客户端标识');
      return;
    }
    if (name.isEmpty) {
      setState(() => _error = '请填写应用名称');
      return;
    }
    setState(() => _saving = true);
    final ok = await controller.create(
      CreateOAuthClientRequest(
        (b) => b
          ..clientId = clientId
          ..clientName = name
          ..clientSecret =
              'sec-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}'
              '${Random().nextInt(0x7fffffff).toRadixString(36)}'
          ..grantTypes = 'authorization_code,client_credentials'
          ..redirectUris = _redirectUris.text.trim()
          ..scopes = _scopes.text.trim(),
      ),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = '保存失败，请重试';
      });
    }
  }

// ……（节略：表单骨架，clientId 创建后不可改，编辑态底部印「密钥不回显」）
}