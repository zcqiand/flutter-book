// @entry M00.F03.I02
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saas_identity_platform_flutter/generated/saas_shared_generated.dart';

import 'role_providers.dart';

/// 角色表单弹窗（M00.F03.I02 创建 + I04 更新，双态，member_form_dialog 同构）：
/// existing == null = 创建（契约 `CreateSysRoleRequest` 恰 clientId/roleCode/
/// roleName 必填 + description/isPreset 可选——isPreset 后端固定 false 不收）；
/// 非空 = 编辑（契约 `UpdateSysRoleRequest` 的 UI 面恰 roleName/description，
/// status 端点在但树口径「不动权限与菜单绑定」不呈现）。选填留空不随 body。
class RoleFormDialog extends ConsumerStatefulWidget {
// ……（节略：字段与生命周期，member_form_dialog 同构）

  Future<void> _save() async {
    if (_saving) return;
    if (!_isEdit &&
        (_clientCtrl.text.trim().isEmpty ||
            _codeCtrl.text.trim().isEmpty ||
            _nameCtrl.text.trim().isEmpty)) {
      setState(() => _error = '请完整填写客户端标识、角色代码与角色名称');
      return;
    }
    if (_isEdit && _nameCtrl.text.trim().isEmpty) {
      setState(() => _error = '角色名称不能为空');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final api = ref.read(roleApiProvider);
      if (_isEdit) {
        await api.tenantRolesUpdateSysRole(
          tenantId: widget.tenantId,
          roleId: widget.existing!.id,
          updateSysRoleRequest: UpdateSysRoleRequest(
            (b) => b
              ..roleName = _nameCtrl.text.trim()
              ..description = _optional(_descCtrl.text),
          ),
        );
      } else {
        await api.tenantRolesCreateSysRole(
          tenantId: widget.tenantId,
          createSysRoleRequest: CreateSysRoleRequest(
            (b) => b
              ..clientId = _clientCtrl.text.trim()
              ..roleCode = _codeCtrl.text.trim()
              ..roleName = _nameCtrl.text.trim()
              ..description = _optional(_descCtrl.text),
          ),
        );
      }
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

  /// 选填留空不随 body（契约可空字段，禁空串兜底）。
  String? _optional(String text) => text.trim().isEmpty ? null : text.trim();

// ……（节略：输入装饰与弹窗骨架）
}